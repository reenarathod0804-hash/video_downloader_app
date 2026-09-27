import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_dloader/appExtension.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/feature/home/presentation/data/model/downloadScreenProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/screen/Home/video%20player.dart';
import 'package:video_dloader/widget/CustomAlertBox.dart';
import 'package:video_dloader/widget/CustomAlertBox2.dart';

class DownloadFile extends StatefulWidget {
  const DownloadFile({super.key});

  @override
  State<DownloadFile> createState() => _DownloadFileState();
}

class _DownloadFileState extends State<DownloadFile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DownloadProvider>().loadDownloads();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          context.t('DownloadedFile'),
        ),
      ),
      body: Consumer<DownloadProvider>(
        builder: (context, downloadProvider, child) {
          final files = downloadProvider.downloadedFiles;

          if (files.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/images/svgs/empty.svg'),
                  const SizedBox(height: 16),
                  Text(
                    context.t('No Video Downloaded'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => downloadProvider.loadDownloads(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index] as File;
                final fileName = file.path.split('/').last;
                final fileSize = file.existsSync()
                    ? downloadProvider.formatBytes(file.lengthSync())
                    : '--';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.borderColor.withOpacity(0.25),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tap to Play thumbnail and info
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VideoPlayerScreen(videoPath: file.path),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 0.18,
                                    height: size.width * 0.14,
                                    decoration: BoxDecoration(
                                      color: AppColors.tomato.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      color: AppColors.tomato,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fileName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          fileSize,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Niramit Bold',
                                            color: AppColors.onboard,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Actions Popup Menu
                          PopupMenuButton<String>(
                            menuPadding: EdgeInsets.zero,
                            color: Colors.white,
                            offset: const Offset(0, 45),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            icon: Icon(
                              Icons.more_vert,
                              color: AppColors.tomato,
                            ),
                            onSelected: (value) async {
                              if (value == 'play') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VideoPlayerScreen(videoPath: file.path),
                                  ),
                                );
                              } else if (value == 'share') {
                                await downloadProvider.shareFile(file.path);
                              } else if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return CustomAlertBox(
                                      title: context.t('Delete Video'),
                                      desc: context.t('deleteDesc'),
                                      buttonText1: context.t('YES'),
                                      buttonText2: context.t('NO'),
                                      onTap1: () async {
                                        Navigator.pop(dialogContext);
                                        await downloadProvider.deleteFile(file);
                                      },
                                      onTap2: () {
                                        Navigator.pop(dialogContext);
                                      },
                                    );
                                  },
                                );
                              } else if (value == 'rename') {
                                final currentBaseName = fileName.contains('.')
                                    ? fileName.substring(0, fileName.lastIndexOf('.'))
                                    : fileName;
                                final tempController =
                                    TextEditingController(text: currentBaseName);

                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return CustomAlertBox2(
                                      title: context.t('Rename Video'),
                                      controller: tempController,
                                      buttonText1: context.t('CANCEL'),
                                      buttonText2: context.t('SAVE'),
                                      onTap: () async {
                                        final newName = tempController.text.trim();
                                        if (newName.isNotEmpty) {
                                          Navigator.pop(dialogContext);
                                          await downloadProvider.renameFile(
                                              file, newName);
                                        }
                                      },
                                    );
                                  },
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: 'play',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.play_arrow, color: Colors.black87),
                                  title: const Text('Play'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'share',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: SvgPicture.asset(
                                      'assets/images/svgs/share.svg'),
                                  title: Text(
                                    context.t('Share'),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'rename',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: SvgPicture.asset(
                                      'assets/images/svgs/rename.svg'),
                                  title: Text(
                                    context.t('Rename'),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: SvgPicture.asset(
                                      'assets/images/svgs/delete.svg'),
                                  title: Text(
                                    context.t('Delete'),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
