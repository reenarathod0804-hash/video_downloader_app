import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:provider/provider.dart';
import 'package:video_dloader/appExtension.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/feature/home/presentation/data/model/tabScreenProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/screen/Home/download_screen.dart';
import 'package:video_dloader/feature/home/presentation/data/screen/Home/home_screen.dart';
import 'package:video_dloader/feature/home/presentation/data/screen/Home/progress_screen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    final tabProviderModel = context.read<TabProvider>();
    tabProviderModel.motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<TabProvider>(
        builder: ((context, providerTab, child) => TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: providerTab.motionTabBarController,
            children: [Home(), ProgressScreen(), DownloadsPage()])),
      ),
      bottomNavigationBar: Consumer<TabProvider>(
        builder: ((context, tabProvider, child) => MotionTabBar(
              onTabItemSelected: (int value) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                tabProvider.select(value);
              },
              textStyle: TextStyle(color: AppColors.tomato),
              tabIconColor: AppColors.indicator,
              tabSelectedColor: AppColors.midpointColor,
              tabIconSize: 30,
              tabIconSelectedSize: 30,
              controller: tabProvider.motionTabBarController,
              initialSelectedTab: context.t('Home'),
              labels: [context.t('Home'), context.t('Progress'), context.t('Download')],
              icons: [Icons.home, Icons.download, Icons.cloud_done],
            )),
      ),
    );
  }
}
