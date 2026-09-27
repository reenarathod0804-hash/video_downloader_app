import 'package:share_plus/share_plus.dart';
import 'package:video_dloader/feature/home/presentation/data/model/OnBoardModel.dart';
import 'package:video_dloader/feature/home/presentation/data/model/drawerModel.dart';
import 'package:video_dloader/feature/home/presentation/data/screen/Setting/DownloadDesc.dart';
import 'package:video_dloader/feature/home/presentation/data/screen/Setting/DownloadFile.dart';
import 'package:video_dloader/feature/home/presentation/data/screen/Setting/PolicyScreen.dart';
import 'package:video_dloader/feature/home/presentation/data/screen/Setting/Setting.dart';

void shareApp() {
  Share.share(
    'Download this amazing video downloader app now! ',
    subject: 'Check out this awesome video downloader!',
  );
}

final List<OnBoardModel> onBoard = [
  OnBoardModel(
      image: 'assets/images/svgs/board1.svg',
      title: 'Easy to Use',
      subTitle:
          'Effortlessly download videos in seconds with our fast, user-friendly app.'),
  OnBoardModel(
      image: 'assets/images/svgs/board2.svg',
      title: 'Easy Download',
      subTitle:
          'Quickly and easily download videos in your preferred format with just a few taps.'),
  OnBoardModel(
      image: 'assets/images/svgs/boaard3.svg',
      title: 'All Video Download',
      subTitle: 'An app to quickly download videos from various platforms.'),
];
final List<DrawerModel> drawerList = [
  DrawerModel(
      image: 'assets/images/svgs/unfillledHome.svg',
      titleKey: 'Home',
      filledImage: 'assets/images/svgs/homeIcon.svg',
      screen: null,
      onTap: null),
  DrawerModel(
      image: 'assets/images/svgs/downloadIcon.svg',
      titleKey: 'How To Download',
      filledImage: 'assets/images/svgs/filldownload.svg',
      screen: DownloadDesc(),
      onTap: null),
  DrawerModel(
      image: 'assets/images/svgs/privacyIcon.svg',
      titleKey: 'Privacy Policy',
      filledImage: 'assets/images/svgs/filledPrivacy.svg',
      screen: PolicyScreen(),
      onTap: null),
  DrawerModel(
    image: 'assets/images/svgs/shareicon.svg',
    titleKey: 'Share App',
    filledImage: 'assets/images/svgs/filledShare.svg',
    screen: null,
    onTap: () {
      shareApp();
    },
  ),
  DrawerModel(
      image: 'assets/images/svgs/downloadFileIcon.svg',
      titleKey: 'Downloaded Files',
      filledImage: 'assets/images/svgs/fillDownloadFile.svg',
      screen: DownloadFile(),
      onTap: null),
  DrawerModel(
      image: 'assets/images/svgs/settingicon.svg',
      titleKey: 'Settings',
      filledImage: 'assets/images/svgs/filledSetting.svg',
      screen: Setting(),
      onTap: null),
];
