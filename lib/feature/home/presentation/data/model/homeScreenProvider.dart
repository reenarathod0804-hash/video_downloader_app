import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomeProvider with ChangeNotifier {
  int isSelect = 0;
  TextEditingController textEditingController = TextEditingController();
  YoutubePlayerController? youtubePlayerController;
  
  String? videoId;
  String? videoTitle;
  String? videoAuthor;
  String? videoDuration;
  String? videoThumbnail;
  bool isLoadingInfo = false;
  String? errorMessage;

  void selectedOption(int index) {
    isSelect = index;
    notifyListeners();
  }

  Future<void> loadVideoFromURL(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      videoId = null;
      videoTitle = null;
      videoAuthor = null;
      videoDuration = null;
      videoThumbnail = null;
      errorMessage = null;
      isLoadingInfo = false;
      notifyListeners();
      return;
    }

    String? id = YoutubePlayer.convertUrlToId(cleanUrl);
    if (id == null && cleanUrl.length == 11 && !cleanUrl.contains('/')) {
      id = cleanUrl;
    }

    if (id != null) {
      videoId = id;
      videoThumbnail = 'https://img.youtube.com/vi/$id/hqdefault.jpg';
      isLoadingInfo = true;
      errorMessage = null;
      notifyListeners();

      final yt = YoutubeExplode();
      try {
        print("🔍 [HomeProvider] Fetching video metadata for ID: $id");
        final video = await yt.videos.get(id);
        videoTitle = video.title;
        videoAuthor = video.author;
        if (video.duration != null) {
          final minutes = video.duration!.inMinutes.remainder(60).toString().padLeft(2, '0');
          final seconds = video.duration!.inSeconds.remainder(60).toString().padLeft(2, '0');
          final hours = video.duration!.inHours > 0 ? '${video.duration!.inHours}:' : '';
          videoDuration = '$hours$minutes:$seconds';
        }
        videoThumbnail = video.thumbnails.highResUrl;
        print("✅ [HomeProvider] Successfully fetched: ${video.title}");
      } catch (e, stackTrace) {
        print("❌ [HomeProvider Error] Error fetching video details: $e");
        print("❌ [Stack Trace]:\n$stackTrace");
        debugPrint("Error fetching video details: $e");
        videoTitle = "YouTube Video ($id)";
      } finally {
        yt.close();
        isLoadingInfo = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    youtubePlayerController?.dispose();
    super.dispose();
  }
}
