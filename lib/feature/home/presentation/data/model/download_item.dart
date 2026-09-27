enum DownloadStatus {
  queued,
  downloading,
  merging,
  completed,
  failed,
  cancelled,
}

class DownloadItem {
  final String id;
  String title;
  String thumbnailUrl;
  final String? duration;
  final String? quality;
  double progress; // 0.0 to 1.0
  String downloadedSize;
  String totalSize;
  DownloadStatus status;
  String? filePath;
  String? errorMessage;
  bool isCancelled;

  DownloadItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    this.duration,
    this.quality,
    this.progress = 0.0,
    this.downloadedSize = '0 MB',
    this.totalSize = '--',
    this.status = DownloadStatus.queued,
    this.filePath,
    this.errorMessage,
    this.isCancelled = false,
  });

  String get statusText {
    switch (status) {
      case DownloadStatus.queued:
        return 'Queued';
      case DownloadStatus.downloading:
        return 'Downloading ${(progress * 100).toStringAsFixed(0)}%';
      case DownloadStatus.merging:
        return 'Processing audio/video...';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return errorMessage ?? 'Download failed';
      case DownloadStatus.cancelled:
        return 'Cancelled';
    }
  }
}
