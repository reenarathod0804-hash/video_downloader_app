import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_dloader/appExtension.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/feature/home/presentation/data/model/downloadScreenProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/model/download_item.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        centerTitle: true,
        title: Text(
          context.t('PROGRESS VIDEOS'),
        ),
      ),
      body: Consumer<DownloadProvider>(
        builder: (context, downloadProvider, child) {
          final tasks = downloadProvider.activeTasks;

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/images/svgs/empty.svg'),
                  const SizedBox(height: 16),
                  Text(
                    'No Video In Progress',
                    style: Theme.of(context).textTheme.titleSmall,
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final item = tasks[index];
              final percent = (item.progress * 100).toInt();

              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.borderColor.withOpacity(0.25),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail with fallback
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: size.width * 0.25,
                            height: size.width * 0.18,
                            child: Image.network(
                              item.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.video_library, color: Colors.grey),
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Details and Progress Bar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (item.status == DownloadStatus.downloading ||
                                          item.status == DownloadStatus.queued) {
                                        downloadProvider.cancelDownload(item.id);
                                      } else {
                                        downloadProvider.removeTask(item.id);
                                      }
                                    },
                                    child: Image.asset(
                                      'assets/images/png/close.png',
                                      height: 18,
                                      width: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${item.downloadedSize} / ${item.totalSize}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  if (item.quality != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.tomato.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.quality!,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.tomato,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Live Progress Bar
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 14,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: item.progress,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          item.status == DownloadStatus.failed
                                              ? Colors.red
                                              : AppColors.tomato,
                                        ),
                                        backgroundColor: AppColors.indicator,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$percent%',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontFamily: 'Niramit Regular',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.statusText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'Niramit Regular',
                                        color: item.status == DownloadStatus.failed
                                            ? Colors.red
                                            : (item.status == DownloadStatus.completed
                                                ? Colors.green
                                                : AppColors.onboard),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (item.status == DownloadStatus.completed)
                                    const Icon(Icons.check_circle, size: 16, color: Colors.green)
                                  else if (item.status == DownloadStatus.failed)
                                    const Icon(Icons.error, size: 16, color: Colors.red)
                                  else
                                    const SizedBox(
                                      height: 12,
                                      width: 12,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
