import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_dloader/appLocalization.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/core/constant/app_constant.dart';
import 'package:video_dloader/feature/home/presentation/data/model/downloadScreenProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/model/homeScreenProvider.dart';
import 'package:video_dloader/appExtension.dart';
import 'package:video_dloader/widget/CustomElevatedButton.dart';
import 'package:video_dloader/feature/home/presentation/data/model/tabScreenProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/widget/quality_selection_sheet.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 33),
          child: Text(
            context.t('appTitle'),
            style: TextStyle(fontFamily: 'League Spartan-Bold'),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 33),
          child: Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu),
            );
          }),
        ),
      ),
      body: Consumer<HomeProvider>(
        builder: ((context, homeProvider, child) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.textField,
                  ),
                  child: TextField(
                    controller: homeProvider.textEditingController,
                    style: TextStyle(fontSize: 14),
                    onChanged: (text) {
                      homeProvider.loadVideoFromURL(text);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 6, top: 3),
                        child: Icon(Icons.link),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      hintText: context.t('textHint'),
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColors.onboard,
                        fontFamily: 'Niramit Regular',
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: homeProvider.videoId != null
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Video Thumbnail with Duration Badge
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: homeProvider.videoThumbnail != null
                                        ? Image.network(
                                            homeProvider.videoThumbnail!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.video_library, size: 48, color: Colors.grey),
                                            ),
                                          )
                                        : Container(color: Colors.grey.shade200),
                                  ),
                                ),
                                if (homeProvider.videoDuration != null)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.75),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        homeProvider.videoDuration!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontFamily: 'League Spartan-Bold',
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (homeProvider.isLoadingInfo)
                              const LinearProgressIndicator(minHeight: 2),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    homeProvider.videoTitle ?? "YouTube Video",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  if (homeProvider.videoAuthor != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.account_circle, size: 16, color: AppColors.onboard),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            homeProvider.videoAuthor!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        height: 180,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.textField.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_collection_outlined, size: 48, color: AppColors.onboard.withOpacity(0.6)),
                            const SizedBox(height: 10),
                            Text(
                              'Paste a YouTube link above',
                              style: TextStyle(
                                color: AppColors.onboard,
                                fontFamily: 'Niramit Regular',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                width: size.width > 500 ? 320 : size.width * 0.75,
                height: 50,
                borderRadius: BorderRadius.circular(10),
                buttonText: context.t('DOWNLOAD'),
                onTap: () async {
                  final input = homeProvider.textEditingController.text.trim();
                  final videoTarget = input.isNotEmpty ? input : (homeProvider.videoId ?? '');
                  if (videoTarget.isEmpty) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a YouTube link or video ID'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  // Show quality selection options (1080p, 360p, 270p)
                  final selectedQuality = await QualitySelectionSheet.show(
                    context,
                    videoTitle: homeProvider.videoTitle,
                  );

                  if (selectedQuality == null || !context.mounted) return;

                  context.read<DownloadProvider>().startDownload(
                    videoTarget,
                    quality: selectedQuality,
                    onMessage: (msg) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'VIEW',
                              textColor: Colors.white,
                              onPressed: () {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                context.read<TabProvider>().select(1);
                              },
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
                fontSize: 18,
              ),
            ],
          ),
        )),
      ),
      drawer: Consumer<HomeProvider>(
        builder: ((context, homeModel, child) => Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: size.height * 0.15,
                child: DrawerHeader(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Text(
                      context.t('appTitle'),
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'League Spartan-Bold',
                      ),
                    ),
                  ),
                ),
              ),
              ListView.builder(
                padding: EdgeInsets.only(top: 30),
                itemCount: drawerList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final drawerItem = drawerList[index];
                  String title = LocalizationService.of(context)
                      .translate(drawerItem.titleKey);

                  return Container(
                    color: homeModel.isSelect == index
                        ? AppColors.tomato.withOpacity(0.1)
                        : Colors.white,
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (drawerItem.screen != null) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => drawerItem.screen!));
                        }
                        homeModel.selectedOption(index);
                      },
                      title: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Niramit Regular',
                          color: homeModel.isSelect == index
                              ? AppColors.pinkFF
                              : AppColors.onboard,
                        ),
                      ),
                      leading: SvgPicture.asset(
                        homeModel.isSelect == index
                            ? drawerItem.filledImage
                            : drawerItem.image,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        )),
      ),
    );
  }
}

