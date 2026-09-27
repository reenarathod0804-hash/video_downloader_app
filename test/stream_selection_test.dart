import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

int parseQualityHeight(String quality) {
  if (quality.contains('1080')) return 1080;
  if (quality.contains('270')) return 270;
  return 360;
}

(MuxedStreamInfo?, VideoStreamInfo?, AudioStreamInfo?) resolveStreams(StreamManifest manifest, String quality) {
  final targetHeight = parseQualityHeight(quality);

  // Strategy 1: Look for exact height match in muxed
  if (manifest.muxed.isNotEmpty) {
    final matches = manifest.muxed.where((m) => m.videoResolution.height == targetHeight).toList();
    if (matches.isNotEmpty) {
      final mp4s = matches.where((m) => m.container.name.toLowerCase() == 'mp4').toList();
      if (mp4s.isNotEmpty) {
        mp4s.sort((a, b) => b.bitrate.compareTo(a.bitrate));
        return (mp4s.first, null, null);
      }
      matches.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      return (matches.first, null, null);
    }
  }

  // Strategy 2: VideoOnly + AudioOnly
  VideoStreamInfo? videoInfo;
  final exactMatches = manifest.videoOnly.where((v) => v.videoResolution.height == targetHeight).toList();
  if (exactMatches.isNotEmpty) {
    final mp4s = exactMatches.where((v) => v.container.name.toLowerCase() == 'mp4').toList();
    if (mp4s.isNotEmpty) {
      mp4s.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      videoInfo = mp4s.first;
    } else {
      exactMatches.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      videoInfo = exactMatches.first;
    }
  } else {
    final sorted = manifest.videoOnly.toList();
    sorted.sort((a, b) {
      final diffA = (a.videoResolution.height - targetHeight).abs();
      final diffB = (b.videoResolution.height - targetHeight).abs();
      if (diffA != diffB) return diffA.compareTo(diffB);

      final aIsMp4 = a.container.name.toLowerCase() == 'mp4' ? 1 : 0;
      final bIsMp4 = b.container.name.toLowerCase() == 'mp4' ? 1 : 0;
      if (aIsMp4 != bIsMp4) return bIsMp4.compareTo(aIsMp4);

      return b.bitrate.compareTo(a.bitrate);
    });
    if (sorted.isNotEmpty) {
      videoInfo = sorted.first;
    }
  }

  AudioStreamInfo? audioInfo;
  if (manifest.audioOnly.isNotEmpty) {
    final mp4Audios = manifest.audioOnly.where(
      (a) => a.container.name.toLowerCase() == 'mp4' || a.audioCodec.toLowerCase().contains('mp4a')
    ).toList();
    if (mp4Audios.isNotEmpty) {
      mp4Audios.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      audioInfo = mp4Audios.first;
    } else {
      audioInfo = manifest.audioOnly.withHighestBitrate();
    }
  }

  return (null, videoInfo, audioInfo);
}

void main() {
  test('Test resolveStreams for 360, 270, 1080', () async {
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest('dQw4w9WgXcQ');

      for (final q in ['1080p', '360p', '270p']) {
        final (muxed, video, audio) = resolveStreams(manifest, q);
        if (muxed != null) {
          print('Quality $q -> MUXED: ${muxed.qualityLabel}, ${muxed.videoResolution.height}p, ${muxed.container.name}');
          expect(muxed.videoResolution.height, 360);
        } else {
          print('Quality $q -> SEPARATE: Video=${video?.qualityLabel} (${video?.videoResolution.height}p, ${video?.container.name}), Audio=${audio?.audioCodec} (${audio?.container.name})');
          expect(video, isNotNull);
          expect(audio, isNotNull);
          if (q == '1080p') {
            expect(video!.videoResolution.height, 1080);
          } else if (q == '270p') {
            expect(video!.videoResolution.height <= 360, isTrue);
          }
        }
      }
    } finally {
      yt.close();
    }
  });
}
