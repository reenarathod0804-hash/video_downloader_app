import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_dloader/appExtension.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/widget/CustomElevatedButton.dart';

class DownloadDesc extends StatefulWidget {
  const DownloadDesc({super.key});

  @override
  State<DownloadDesc> createState() => _DownloadDescState();
}

class _DownloadDescState extends State<DownloadDesc> {
  List list = ['High (1080p)', 'Medium (720p)', 'Low (480p)'];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            context.t('How To Download'),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t('Step:1'),
                    style: Theme.of(context).textTheme.titleMedium),
                SizedBox(
                  height: size.height * 0.008,
                ),
                Text(
                  context.t('Step1Desk'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.lightPink.withOpacity(0.1)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Text(
                              context.t('Video downloader'),
                              style: TextStyle(
                                  fontSize: 16, fontFamily: 'Niramit Bold'),
                            ),
                            SizedBox(
                              height: size.height * 0.015,
                            ),
                            Container(
                              width: size.width * 0.920,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.onboard.withOpacity(0.16),
                              ),
                              child: TextField(
                                readOnly: true,
                                style: TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 6, top: 3),
                                    child: Icon(Icons.link),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 20),
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
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: -20,
                        left: 170.0,
                        child: SvgPicture.asset(
                          'assets/images/svgs/hand2.svg',
                          height: size.height * 0.065,
                        ))
                  ],
                ),
                SizedBox(
                  height: size.height * 0.04,
                ),
                Text(context.t('Step2'),
                    style: Theme.of(context).textTheme.titleMedium),
                SizedBox(
                  height: size.height * 0.008,
                ),
                Text(
                  context.t('Step2desk'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: size.height * 0.23,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.lightPink.withOpacity(0.1)),
                      child: Stack(
                        children: [
                          Center(
                              child:
                                  Image.asset('assets/images/svgs/vdo2.png')),
                          Center(
                              child: Image.asset(
                            'assets/images/png/pausebutton.png',
                            height: 50,
                          )),
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: -13,
                        left: 170.0,
                        child: SvgPicture.asset(
                          'assets/images/svgs/hand2.svg',
                          height: size.height * 0.065,
                        ))
                  ],
                ),
                SizedBox(
                  height: size.height * 0.04,
                ),
                Text(context.t('Step3'),
                    style: Theme.of(context).textTheme.titleMedium),
                SizedBox(
                  height: size.height * 0.008,
                ),
                Text(
                  context.t('Step3Desk'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      // height: size.height * 0.41,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.lightPink.withOpacity(0.1)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height * 0.025,
                          ),
                          Center(
                            child: CustomElevatedButton(
                              width: size.width * 0.7,
                              height: size.height * 0.065,
                              borderRadius: BorderRadius.circular(10),
                              buttonText: context.t('DOWNLOAD'),
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.025,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: -25,
                        left: 170.0,
                        child: SvgPicture.asset(
                          'assets/images/svgs/hand2.svg',
                          height: size.height * 0.065,
                        )),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
              ],
            ),
          ),
        ));
  }
}
