import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_explode_webview/youtube_explode_webview.dart';
import 'package:video_dloader/feature/home/presentation/data/model/download_item.dart';

class DownloadProvider with ChangeNotifier {
  // YouTube occasionally accepts the metadata request but never starts the
  // stream response.  Without a timeout the UI remains at its initial value
  // forever, which looks like a download stuck at 1%.
  static const _metadataTimeout = Duration(seconds: 20);
  // Do not allow YoutubeExplode's internal refresh loop to leave the UI at
  // 0% indefinitely when a CDN refuses a high-resolution stream.
  static const _streamInactivityTimeout = Duration(seconds: 12);

  final List<DownloadItem> _activeTasks = [];
  List<FileSystemEntity> _downloadedFiles = [];

  List<DownloadItem> get activeTasks => _activeTasks;
  List<FileSystemEntity> get downloadedFiles => _downloadedFiles;

  DownloadProvider() {
    loadDownloads();
  }

  // Get reliable download directory with safe fallbacks
  Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      try {
        final publicDir =
            Directory('/storage/emulated/0/Download/YouTubeDownloads');
        if (!await publicDir.exists()) {
          await publicDir.create(recursive: true);
        }
        // Test write ability
        final testFile = File('${publicDir.path}/.test_write');
        await testFile.writeAsString('test');
        await testFile.delete();
        return publicDir;
      } catch (_) {
        // Fallback to app external or internal storage
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final appDir = Directory('${extDir.path}/YouTubeDownloads');
          if (!await appDir.exists()) {
            await appDir.create(recursive: true);
          }
          return appDir;
        }
      }
    }

    final docDir = await getApplicationDocumentsDirectory();
    final fallbackDir = Directory('${docDir.path}/YouTubeDownloads');
    if (!await fallbackDir.exists()) {
      await fallbackDir.create(recursive: true);
    }
    return fallbackDir;
  }

  // Handle permissions gracefully
  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      if (await Permission.videos.isGranted ||
          await Permission.storage.isGranted) {
        return true;
      }

      // Try modern media permissions first, then fallback to storage
      final videoStatus = await Permission.videos.request();
      if (videoStatus.isGranted) return true;

      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } catch (_) {
      return true; // Proceed with app-internal storage fallback
    }
  }

  // Format bytes to readable string (e.g., "15.4 MB")
  String formatBytes(int bytes) {
    if (bytes <= 0) return "0 MB";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double count = bytes.toDouble();
    while (count >= 1024 && i < suffixes.length - 1) {
      count /= 1024;
      i++;
    }
    return '${count.toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Cancel an active download task
  void cancelDownload(String taskId) {
    final index = _activeTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _activeTasks[index].isCancelled = true;
      _activeTasks[index].status = DownloadStatus.cancelled;
      notifyListeners();
    }
  }

  // Remove a task from the active list
  void removeTask(String taskId) {
    _activeTasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  int _parseQualityHeight(String quality) {
    if (quality.contains('1080')) return 1080;
    if (quality.contains('720')) return 720;
    if (quality.contains('480')) return 480;
    if (quality.contains('360')) return 360;
    if (quality.contains('240')) return 240;
    if (quality.contains('144')) return 144;
    return 360; // safe default
  }

  Future<T> _withMetadataTimeout<T>(Future<T> request, String operation) {
    return request.timeout(
      _metadataTimeout,
      onTimeout: () => throw TimeoutException(
        'YouTube did not respond while $operation. Please try again.',
      ),
    );
  }

  Stream<List<int>> _withStreamTimeout(Stream<List<int>> stream) {
    return stream.timeout(
      _streamInactivityTimeout,
      onTimeout: (sink) {
        sink.addError(TimeoutException(
          'The video stream stopped responding. Please try the download again.',
        ));
        sink.close();
      },
    );
  }

  /// Uses youtube_explode_dart's stream client rather than requesting the
  /// signed GoogleVideo URL ourselves. A signed URL can expire or be rejected
  /// with HTTP 403; the package refreshes its manifest and retries that stream.
  Stream<List<int>> _downloadStream(YoutubeExplode yt, StreamInfo streamInfo) {
    return _withStreamTimeout(yt.videos.streamsClient.get(streamInfo));
  }

  // Main download method with real-time stream chunk tracking, quality selection, and duplicate prevention
  Future<void> startDownload(String videoInput,
      {String quality = '360p', Function(String)? onMessage}) async {
    String rawInput = videoInput.trim();
    if (rawInput.isEmpty) {
      onMessage?.call("Please enter a valid YouTube URL or Video ID");
      return;
    }

    String? videoId;
    try {
      final parsedId = VideoId(rawInput);
      videoId = parsedId.value;
    } catch (_) {
      videoId = rawInput;
    }

    final taskId = '${videoId}_$quality';

    // Check 1: Prevent duplicate active download tasks
    if (_activeTasks.any((t) =>
        t.id == taskId &&
        (t.status == DownloadStatus.downloading ||
            t.status == DownloadStatus.queued ||
            t.status == DownloadStatus.merging))) {
      onMessage?.call(
          "This video ($quality) is already downloading in Progress tab.");
      return;
    }

    DownloadItem item = DownloadItem(
      id: taskId,
      title: "Fetching video information...",
      thumbnailUrl: "https://img.youtube.com/vi/$videoId/hqdefault.jpg",
      quality: quality,
      status: DownloadStatus.queued,
    );

    // Remove any previous failed/cancelled task for same task ID
    _activeTasks.removeWhere((t) => t.id == taskId);
    _activeTasks.insert(0, item);
    notifyListeners();

    try {
      // YouTube may require a JavaScript challenge response before granting
      // an adaptive stream such as 1080p. This is the extractor's supported
      // Flutter solver for those signed stream URLs.
      final solver = await WebviewEJSSolver.init();
      final yt = YoutubeExplode(jsSolver: solver);

      try {
        await requestStoragePermission();

        final video = await _withMetadataTimeout(
          yt.videos.get(videoId),
          'fetching video information',
        );
        print(
            "🚀 [Download Started] Video ID: $videoId, Quality: $quality, Title: ${video.title}");
        final downloadDir = await getDownloadDirectory();
        print("📁 [Download Directory] ${downloadDir.path}");

        final safeTitle =
            video.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
        final finalFileName = safeTitle.isEmpty ? 'video_$videoId' : safeTitle;
        final targetPath = '${downloadDir.path}/${finalFileName}_$quality.mp4';

        // Check 2: Prevent duplicate completed files on disk
        if (await File(targetPath).exists()) {
          print("ℹ️ [Download Info] File already exists at $targetPath");
          _activeTasks.removeWhere((t) => t.id == taskId);
          notifyListeners();
          onMessage?.call(
              "Video ($quality) is already downloaded! Check the Downloads tab.");
          return;
        }

        item = _activeTasks.firstWhere((t) => t.id == taskId);
        item.title = video.title;
        item.thumbnailUrl = video.thumbnails.highResUrl;
        // Do not show artificial progress.  Progress starts when the first
        // bytes arrive, and timeouts below turn a stalled request into an error.
        item.progress = 0.0;
        item.status = DownloadStatus.downloading;
        notifyListeners();
        onMessage?.call("Download started ($quality)!");

        print(
            "🔍 [Download Provider] Fetching stream manifest for $videoId...");
        StreamManifest? manifest;
        // Track whether we fell back to the default client. When iOS/TV both
        // return 403, the default client usually resolves the manifest but its
        // adaptive (video-only) streams are also blocked — we must avoid them.
        bool usingDefaultClient = false;
        final clientAttempts = [
          // Android media URLs are currently the source of the 403/zero-byte
          // response on this device. Prefer iOS, which returns a separate
          // signed URL for the same adaptive 1080p stream.
          [YoutubeApiClient.ios],
          [YoutubeApiClient.tv],
          null, // default
          [YoutubeApiClient.android],
        ];

        for (final clients in clientAttempts) {
          try {
            final resolvedManifest = clients != null
                ? await _withMetadataTimeout(
                    yt.videos.streamsClient
                        .getManifest(video.id, ytClients: clients),
                    'fetching a stream manifest',
                  )
                : await _withMetadataTimeout(
                    yt.videos.streamsClient.getManifest(video.id),
                    'fetching a stream manifest',
                  );
            manifest = resolvedManifest;

            if (resolvedManifest.muxed.isNotEmpty ||
                (resolvedManifest.videoOnly.isNotEmpty &&
                    resolvedManifest.audioOnly.isNotEmpty)) {
              usingDefaultClient = (clients == null);
              print(
                  "✅ [Download Provider] Resolved stream manifest with: ${clients ?? 'default'} (defaultClient=$usingDefaultClient)");
              break;
            }
          } catch (e) {
            print(
                "⚠️ [Download Provider] Manifest attempt failed for ${clients ?? 'default'}: $e");
          }
        }

        final selectedManifest = manifest;
        if (selectedManifest == null ||
            (selectedManifest.muxed.isEmpty &&
                (selectedManifest.videoOnly.isEmpty ||
                    selectedManifest.audioOnly.isEmpty))) {
          throw VideoUnplayableException(
              "Unable to extract playable streams for video ID '$videoId' from available YouTube clients.");
        }

        print(
            "📊 [Manifest Info] Muxed streams: ${selectedManifest.muxed.length}, Video-only: ${selectedManifest.videoOnly.length}, Audio-only: ${selectedManifest.audioOnly.length}");

        final targetHeight = _parseQualityHeight(quality);

        // Strategy 1: Check for matching Muxed stream (video + audio already combined)
        MuxedStreamInfo? selectedMuxed;
        if (selectedManifest.muxed.isNotEmpty) {
          final matches = selectedManifest.muxed
              .where((m) => m.videoResolution.height == targetHeight)
              .toList();
          if (matches.isNotEmpty) {
            final mp4s = matches
                .where((m) => m.container.name.toLowerCase() == 'mp4')
                .toList();
            if (mp4s.isNotEmpty) {
              mp4s.sort((a, b) => b.bitrate.compareTo(a.bitrate));
              selectedMuxed = mp4s.first;
            } else {
              matches.sort((a, b) => b.bitrate.compareTo(a.bitrate));
              selectedMuxed = matches.first;
            }
          }

          // When adaptive streams are unreliable (default client fallback or
          // low-quality request), use the closest available muxed stream.
          // The default client's adaptive URLs are almost always blocked by
          // YouTube's per-request signing — skip them entirely to avoid a
          // silent hang that no timeout can recover from.
          final bool preferMuxed = usingDefaultClient || targetHeight <= 360;
          if (selectedMuxed == null && preferMuxed) {
            final fallbackMuxed = selectedManifest.muxed.toList()
              ..sort((a, b) {
                final differenceA =
                    (a.videoResolution.height - targetHeight).abs();
                final differenceB =
                    (b.videoResolution.height - targetHeight).abs();
                if (differenceA != differenceB) {
                  return differenceA.compareTo(differenceB);
                }

                final aIsMp4 = a.container.name.toLowerCase() == 'mp4';
                final bIsMp4 = b.container.name.toLowerCase() == 'mp4';
                if (aIsMp4 != bIsMp4) return aIsMp4 ? -1 : 1;
                return b.bitrate.compareTo(a.bitrate);
              });
            selectedMuxed = fallbackMuxed.first;
            final reason = usingDefaultClient
                ? 'default client (adaptive streams likely blocked)'
                : 'low-quality request';
            print(
                "ℹ️ [Download Provider] Using muxed ${selectedMuxed.qualityLabel} for $quality ($reason).");
            if (usingDefaultClient && selectedMuxed.videoResolution.height < targetHeight) {
              onMessage?.call(
                  "YouTube blocked $quality adaptive streams — downloading ${selectedMuxed.qualityLabel} (best available).");
            }
          }
        }

        if (selectedMuxed != null) {
          // Direct Muxed download (No merge needed)
          print(
              "⚡ [Download Strategy] Using Muxed Stream: ${selectedMuxed.qualityLabel}, Size: ${selectedMuxed.size.totalBytes} bytes");
          final outputPath = targetPath;
          // Write to a temporary name.  A failed stream must never look like a
          // completed file on the next download attempt.
          final partialPath = '$targetPath.part';
          item.totalSize = formatBytes(selectedMuxed.size.totalBytes);
          notifyListeners();

          final stream = _downloadStream(yt, selectedMuxed);
          final file = File(partialPath);
          final output = file.openWrite();

          var count = 0;
          final totalBytes = selectedMuxed.size.totalBytes;

          try {
            await for (final data in stream) {
              if (item.isCancelled) {
                print("⚠️ [Download Cancelled] Task ID: $taskId");
                break;
              }
              count += data.length;
              output.add(data);
              item.progress =
                  totalBytes > 0 ? (count / totalBytes).clamp(0.0, 1.0) : 0.5;
              item.downloadedSize = formatBytes(count);
              notifyListeners();
            }
          } finally {
            await output.flush();
            await output.close();
          }

          if (item.isCancelled) {
            if (await file.exists()) await file.delete();
            return;
          }

          await file.rename(outputPath);

          item.status = DownloadStatus.completed;
          item.progress = 1.0;
          item.filePath = outputPath;
          notifyListeners();
          await loadDownloads();
          print("✅ [Download Success] Video saved to: $outputPath");
          onMessage?.call("Downloaded: ${video.title} ($quality)");
        } else if (selectedManifest.videoOnly.isNotEmpty &&
            selectedManifest.audioOnly.isNotEmpty) {
          // Strategy 2: Download separate video/audio streams and merge with FFmpeg
          VideoStreamInfo? videoStreamInfo;

          // 1. Look for exact height match
          final exactMatches = selectedManifest.videoOnly
              .where((v) => v.videoResolution.height == targetHeight)
              .toList();
          if (exactMatches.isNotEmpty) {
            final mp4s = exactMatches
                .where((v) => v.container.name.toLowerCase() == 'mp4')
                .toList();
            if (mp4s.isNotEmpty) {
              mp4s.sort((a, b) => b.bitrate.compareTo(a.bitrate));
              videoStreamInfo = mp4s.first;
            } else {
              exactMatches.sort((a, b) => b.bitrate.compareTo(a.bitrate));
              videoStreamInfo = exactMatches.first;
            }
          } else {
            // Closest match by resolution
            final candidates = selectedManifest.videoOnly.toList();
            candidates.sort((a, b) {
              final diffA = (a.videoResolution.height - targetHeight).abs();
              final diffB = (b.videoResolution.height - targetHeight).abs();
              if (diffA != diffB) return diffA.compareTo(diffB);

              final aIsMp4 = a.container.name.toLowerCase() == 'mp4' ? 1 : 0;
              final bIsMp4 = b.container.name.toLowerCase() == 'mp4' ? 1 : 0;
              if (aIsMp4 != bIsMp4) return bIsMp4.compareTo(aIsMp4);

              return b.bitrate.compareTo(a.bitrate);
            });
            if (candidates.isNotEmpty) {
              videoStreamInfo = candidates.first;
            }
          }

          if (videoStreamInfo == null) {
            throw Exception("No video stream found for quality $quality");
          }

          // Select audio stream (prefer mp4/m4a with highest bitrate)
          AudioStreamInfo? audioStreamInfo;
          final mp4Audios = selectedManifest.audioOnly
              .where((a) =>
                  a.container.name.toLowerCase() == 'mp4' ||
                  a.audioCodec.toLowerCase().contains('mp4a'))
              .toList();
          if (mp4Audios.isNotEmpty) {
            mp4Audios.sort((a, b) => b.bitrate.compareTo(a.bitrate));
            audioStreamInfo = mp4Audios.first;
          } else {
            audioStreamInfo = selectedManifest.audioOnly.withHighestBitrate();
          }

          print(
              "⚡ [Download Strategy] Using Video+Audio FFmpeg merge: Video=${videoStreamInfo.qualityLabel} (${videoStreamInfo.videoResolution.height}p, ${videoStreamInfo.container.name}), Audio=${audioStreamInfo.audioCodec} (${audioStreamInfo.container.name})");

          final tempVideoExt = videoStreamInfo.container.name.isNotEmpty
              ? videoStreamInfo.container.name
              : 'mp4';
          final tempAudioExt = audioStreamInfo.container.name.isNotEmpty
              ? audioStreamInfo.container.name
              : 'm4a';
          final tempDir = await getTemporaryDirectory();
          final tempVideoPath =
              '${tempDir.path}/temp_${taskId}_v.$tempVideoExt';
          final tempAudioPath =
              '${tempDir.path}/temp_${taskId}_a.$tempAudioExt';
          final outputPath = targetPath;

          final totalBytes =
              videoStreamInfo.size.totalBytes + audioStreamInfo.size.totalBytes;
          item.totalSize = formatBytes(totalBytes);
          notifyListeners();

          // 1. Download Video — catch HTTP 403 (YouTube blocks adaptive streams
          // with per-client signed URLs on many devices/regions).
          print(
              "⬇️ [Downloading Video Stream] Size: ${videoStreamInfo.size.totalBytes} bytes...");
          var totalDownloaded = 0;
          final videoStream = _downloadStream(yt, videoStreamInfo);
          final videoFile = File(tempVideoPath).openWrite();
          bool videoStreamFailed = false;

          try {
            await for (final chunk in videoStream) {
              if (item.isCancelled) {
                print("⚠️ [Download Cancelled] Task ID: $taskId");
                await videoFile.close();
                if (await File(tempVideoPath).exists()) {
                  await File(tempVideoPath).delete();
                }
                return;
              }
              totalDownloaded += chunk.length;
              videoFile.add(chunk);
              item.progress = (totalDownloaded / totalBytes).clamp(0.0, 0.85);
              item.downloadedSize = formatBytes(totalDownloaded);
              notifyListeners();
            }
          } catch (streamErr) {
            videoStreamFailed = true;
            print(
                "⚠️ [Video Stream Error] Adaptive stream blocked (likely 403): $streamErr");
          } finally {
            await videoFile.flush();
            await videoFile.close();
          }

          // If the video-only stream was blocked by YouTube (403 / inactivity
          // timeout), fall back to the best available muxed stream so the user
          // still gets a working download.
          if (videoStreamFailed) {
            if (await File(tempVideoPath).exists()) {
              await File(tempVideoPath).delete();
            }

            if (selectedManifest.muxed.isNotEmpty) {
              // Pick the best muxed stream (closest height, then highest bitrate)
              final fallbackList = selectedManifest.muxed.toList()
                ..sort((a, b) {
                  final diffA =
                      (a.videoResolution.height - targetHeight).abs();
                  final diffB =
                      (b.videoResolution.height - targetHeight).abs();
                  if (diffA != diffB) return diffA.compareTo(diffB);
                  final aIsMp4 = a.container.name.toLowerCase() == 'mp4';
                  final bIsMp4 = b.container.name.toLowerCase() == 'mp4';
                  if (aIsMp4 != bIsMp4) return aIsMp4 ? -1 : 1;
                  return b.bitrate.compareTo(a.bitrate);
                });
              final fallbackMuxed = fallbackList.first;
              print(
                  "♻️ [Fallback] Adaptive stream blocked — using muxed ${fallbackMuxed.qualityLabel} instead of $quality.");
              onMessage?.call(
                  "$quality blocked by YouTube — downloading ${fallbackMuxed.qualityLabel} instead.");

              final fallbackPath =
                  '${downloadDir.path}/${finalFileName}_${fallbackMuxed.qualityLabel}.mp4';
              final fallbackPartPath = '$fallbackPath.part';
              item.totalSize =
                  formatBytes(fallbackMuxed.size.totalBytes);
              notifyListeners();

              final muxedStream = _downloadStream(yt, fallbackMuxed);
              final muxedFile = File(fallbackPartPath);
              final muxedOutput = muxedFile.openWrite();
              var muxedCount = 0;
              final muxedTotal = fallbackMuxed.size.totalBytes;

              try {
                await for (final data in muxedStream) {
                  if (item.isCancelled) {
                    print("⚠️ [Download Cancelled] Task ID: $taskId");
                    break;
                  }
                  muxedCount += data.length;
                  muxedOutput.add(data);
                  item.progress =
                      muxedTotal > 0
                          ? (muxedCount / muxedTotal).clamp(0.0, 1.0)
                          : 0.5;
                  item.downloadedSize = formatBytes(muxedCount);
                  notifyListeners();
                }
              } finally {
                await muxedOutput.flush();
                await muxedOutput.close();
              }

              if (item.isCancelled) {
                if (await muxedFile.exists()) await muxedFile.delete();
                return;
              }

              await muxedFile.rename(fallbackPath);
              item.status = DownloadStatus.completed;
              item.progress = 1.0;
              item.filePath = fallbackPath;
              notifyListeners();
              await loadDownloads();
              print(
                  "✅ [Fallback Download Success] Video saved to: $fallbackPath");
              onMessage?.call(
                  "Downloaded (${fallbackMuxed.qualityLabel}): ${video.title}");
              return; // done — skip FFmpeg merge below
            } else {
              throw Exception(
                  "YouTube blocked the $quality stream (HTTP 403). No fallback muxed stream available.");
            }
          }

          // 2. Download Audio
          print(
              "⬇️ [Downloading Audio Stream] Size: ${audioStreamInfo.size.totalBytes} bytes...");
          final audioStream = _downloadStream(yt, audioStreamInfo);
          final audioFile = File(tempAudioPath).openWrite();

          await for (final chunk in audioStream) {
            if (item.isCancelled) {
              print("⚠️ [Download Cancelled] Task ID: $taskId");
              await audioFile.close();
              if (await File(tempVideoPath).exists()) {
                await File(tempVideoPath).delete();
              }
              if (await File(tempAudioPath).exists()) {
                await File(tempAudioPath).delete();
              }
              return;
            }
            totalDownloaded += chunk.length;
            audioFile.add(chunk);
            item.progress = (totalDownloaded / totalBytes).clamp(0.0, 0.95);
            item.downloadedSize = formatBytes(totalDownloaded);
            notifyListeners();
          }
          await audioFile.flush();
          await audioFile.close();

          // 3. Merge Audio & Video with FFmpeg
          print("🔄 [FFmpeg Merging] Merging streams into $outputPath...");
          item.status = DownloadStatus.merging;
          notifyListeners();

          final command =
              '-y -i "$tempVideoPath" -i "$tempAudioPath" -c:v copy -c:a aac "$outputPath"';
          final session = await FFmpegKit.execute(command);
          final returnCode = await session.getReturnCode();
          final logs = await session.getAllLogsAsString();

          // Clean up temp files
          if (await File(tempVideoPath).exists()) {
            await File(tempVideoPath).delete();
          }
          if (await File(tempAudioPath).exists()) {
            await File(tempAudioPath).delete();
          }

          if (ReturnCode.isSuccess(returnCode)) {
            item.status = DownloadStatus.completed;
            item.progress = 1.0;
            item.filePath = outputPath;
            notifyListeners();
            await loadDownloads();
            print("✅ [Download & Merge Success] Video saved to: $outputPath");
            onMessage?.call("Downloaded: ${video.title} ($quality)");
          } else {
            print("❌ [FFmpeg Merge Failed] ReturnCode: $returnCode");
            print("❌ [FFmpeg Logs]: $logs");
            item.status = DownloadStatus.failed;
            item.errorMessage = "FFmpeg merging failed (code $returnCode)";
            notifyListeners();
          }
        } else {
          throw Exception(
              "No suitable video/audio streams found for this video.");
        }
      } finally {
        yt.close();
        solver.dispose();
      }
    } catch (e, stackTrace) {
      print("❌ [DOWNLOAD ERROR OCCURRED]: $e");
      print("❌ [STACK TRACE]:\n$stackTrace");
      debugPrint("❌ [DOWNLOAD ERROR OCCURRED]: $e");
      debugPrint("❌ [STACK TRACE]:\n$stackTrace");

      String cleanError = "Download failed";
      if (e is VideoUnplayableException ||
          e.toString().contains("VideoUnplayableException")) {
        cleanError =
            "Video is restricted by YouTube (e.g. copyright, music, age-gate)";
      } else if (e is VideoRequiresPurchaseException) {
        cleanError = "Video requires purchase or rental";
      } else if (e is VideoUnavailableException) {
        cleanError = "Video is unavailable or private";
      } else if (e is TimeoutException) {
        cleanError = e.message?.toString() ??
            'YouTube did not respond in time. Please try again.';
      } else if (e is SocketException) {
        cleanError = "Network error: check your internet connection";
      } else {
        cleanError =
            e.toString().split('\n').first.replaceAll('Exception:', '').trim();
      }

      final index = _activeTasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _activeTasks[index].status = DownloadStatus.failed;
        _activeTasks[index].errorMessage = cleanError;
        notifyListeners();
      }
      onMessage?.call(cleanError);
    }
  }

  // Load completed video files from storage
  Future<void> loadDownloads() async {
    try {
      final dir = await getDownloadDirectory();
      if (await dir.exists()) {
        final files = dir
            .listSync()
            .where((f) {
              if (f is! File) return false;
              final fileName = f.path.split('/').last;
              if (fileName.startsWith('temp_') ||
                  fileName.startsWith('.') ||
                  fileName.endsWith('.part') ||
                  fileName.endsWith('.tmp')) {
                return false;
              }
              return f.path.endsWith('.mp4') ||
                  f.path.endsWith('.mkv') ||
                  f.path.endsWith('.webm') ||
                  f.path.endsWith('.avi');
            })
            .toList();

        // Sort by newest first
        files.sort((a, b) {
          final statA = (a as File).lastModifiedSync();
          final statB = (b as File).lastModifiedSync();
          return statB.compareTo(statA);
        });

        _downloadedFiles = files;
        notifyListeners();
      } else {
        _downloadedFiles = [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading downloads: $e");
      _downloadedFiles = [];
      notifyListeners();
    }
  }

  // Delete a downloaded file
  Future<void> deleteFile(FileSystemEntity file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint("Error deleting file: $e");
    } finally {
      await loadDownloads();
    }
  }

  // Rename a downloaded file
  Future<bool> renameFile(FileSystemEntity file, String newName) async {
    try {
      if (!await file.exists()) return false;
      final dir = file.parent.path;
      final extension = file.path.split('.').last;
      final cleanNewName =
          newName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
      final newPath = '$dir/$cleanNewName.$extension';

      await file.rename(newPath);
      return true;
    } catch (e) {
      debugPrint("Error renaming file: $e");
      return false;
    } finally {
      await loadDownloads();
    }
  }

  // Share file
  Future<void> shareFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(filePath)],
            text: file.path.split('/').last);
      }
    } catch (e) {
      debugPrint("Error sharing file: $e");
    }
  }
}
