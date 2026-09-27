import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:video_dloader/appExtension.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/feature/home/presentation/data/model/AlertProvider.dart';
import 'package:video_dloader/widget/CustomElevatedButton.dart';

class AlertBox extends StatefulWidget {
  const AlertBox({super.key});

  @override
  State<AlertBox> createState() => _AlertBoxState();
}

class _AlertBoxState extends State<AlertBox> {
  @override
  void initState() {
    super.initState();
    final alertProvider = context.read<AlertProvider>();
    alertProvider.alertBox = Hive.box('SettingBox');
    alertProvider.loadSavedLocale();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<AlertProvider>(
      builder: (context, alertProvider, child) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  context.t('Language Selection'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: alertProvider.lang.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            alertProvider.changeLanguage(index); // Change selected language
                          },
                          dense: true,
                          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                          title: Text(
                            alertProvider.lang[index],
                            style: TextStyle(
                                fontFamily: 'Niramit Regular',
                                color: AppColors.onboard),
                          ),
                          trailing: alertProvider.selectedLanguage == alertProvider.lang[index]
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: SvgPicture.asset('assets/images/svgs/radioCheck.svg'),
                          )
                              : SizedBox(
                            height: 20,
                            width: 20,
                            child: SvgPicture.asset('assets/images/svgs/radioUnchecked.svg'),
                          ),
                        ),
                        if (index != alertProvider.lang.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Divider(),
                          ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        height: 40,
                        borderRadius: BorderRadius.circular(5),
                        buttonText: context.t('CANCEL'),
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.01,
                    ),
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: () {

                          alertProvider.saveLanguage();
                          Navigator.pop(context);
                        },
                        height: 40,
                        borderRadius: BorderRadius.circular(5),
                        buttonText: context.t('SAVE'),
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.1,
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
