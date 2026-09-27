import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:video_dloader/appExtension.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/feature/home/presentation/data/model/settingProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/widget/AlertBox.dart';
import 'package:video_dloader/feature/home/presentation/data/widget/AlertBox2.dart';
import 'package:video_dloader/widget/CustomAlertBox.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  void initState() {
    // TODO: implement initState
    final settingProvider = context.read<SettingProvider>();
    settingProvider.settingBox = Hive.box('SettingBox');
    settingProvider.isWifi =
        settingProvider.settingBox.get('newValue', defaultValue: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            context.t('SETTINGS'),
          ),
        ),
        body: Consumer<SettingProvider>(
          builder: ((context, settingProvider, child) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: AppColors.onboard.withOpacity(0.25))),
                      child: ListTile(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10)), //this right here
                                    child: AlertBox());
                              });
                        },
                        title: Text(
                          context.t('App Language'),
                          style: TextStyle(fontFamily: 'Niramit Bold'),
                        ),
                        leading:
                            SvgPicture.asset('assets/images/svgs/langIcon.svg'),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.013,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: AppColors.onboard.withOpacity(0.25))),
                      child: ListTile(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10)), //this right here
                                    child: AlertBox2());
                              });
                        },
                        title: Text(
                          context.t('Search Engine'),
                          style: TextStyle(fontFamily: 'Niramit Bold'),
                        ),
                        leading: SvgPicture.asset(
                            'assets/images/svgs/settingIcon2.svg'),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.013,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: AppColors.onboard.withOpacity(0.25))),
                      child: ListTile(
                        title: Text(
                          context.t('Download with Wi-Fi Only'),
                          style: TextStyle(fontFamily: 'Niramit Bold'),
                        ),
                        leading:
                            SvgPicture.asset('assets/images/svgs/wifiIcon.svg'),
                        // contentPadding: EdgeInsets.only(left: 2),
                        trailing: SizedBox(
                          width: size.width * 0.12,
                          height: size.height * 0.04,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Switch(
                              activeTrackColor: AppColors.switchColor,
                              inactiveThumbColor: AppColors.switchIndicator,
                              activeColor: AppColors.pinkFF,
                              value: settingProvider.isWifi,
                              onChanged: (value) {
                                settingProvider.changeValue(value);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.013,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: AppColors.onboard.withOpacity(0.25))),
                      child: ListTile(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomAlertBox(
                                  onTap1: () {
                                    Navigator.pop(context);
                                  },
                                  title: context.t('Clear Cache'),
                                  desc: context
                                      .t('Do you want to clear all cache?'),
                                  buttonText1: context.t('CANCEL'),
                                  buttonText2: context.t('CLEAR'),
                                );
                              });
                        },
                        title: Text(
                          context.t('Clear Cache'),
                          style: TextStyle(fontFamily: 'Niramit Bold'),
                        ),
                        leading: SvgPicture.asset(
                            'assets/images/svgs/cacheIcon.svg'),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.013,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: AppColors.onboard.withOpacity(0.25))),
                      child: ListTile(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomAlertBox(
                                  onTap1: () {
                                    Navigator.pop(context);
                                  },
                                  title: context.t('Clear Browser History'),
                                  desc: context.t(
                                      'Would you like to clear all browser history?'),
                                  buttonText1: context.t('CANCEL'),
                                  buttonText2: context.t('CLEAR'),
                                );
                              });
                        },
                        title: Text(
                          context.t('Clear Browser History'),
                          style: TextStyle(fontFamily: 'Niramit Bold'),
                        ),
                        leading: SvgPicture.asset(
                            'assets/images/svgs/historyIcon.svg'),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }
}
