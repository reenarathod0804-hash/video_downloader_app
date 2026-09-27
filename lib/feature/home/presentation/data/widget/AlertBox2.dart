import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:video_dloader/appExtension.dart';
import 'package:video_dloader/appLocalization.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/core/constant/app_constant.dart';
import 'package:video_dloader/feature/home/presentation/data/model/AlertProvider2.dart';
import 'package:video_dloader/widget/CustomElevatedButton.dart';

class AlertBox2 extends StatefulWidget {
  const AlertBox2({super.key});

  @override
  State<AlertBox2> createState() => _AlertBox2State();
}

class _AlertBox2State extends State<AlertBox2> {
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    final alertProvider=context.read<AlertProvider2>();
    alertProvider.alertBox2=Hive.box('SettingBox');
    alertProvider.isClick=alertProvider.alertBox2.get('newSearch',defaultValue: 0);
    alertProvider.check=alertProvider.alertBox2.get('language',defaultValue: 'Google');
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<AlertProvider2>(
      builder: ((context,alertProvider,child)=>
       Container(
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(10)
         ),
         child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10,bottom: 10),
                child: Text(
                  context.t('Search Engine'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: alertProvider.search.length,
                  itemBuilder: (context, index) {

                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            alertProvider.changeRadioButton(index);

                          },
                          dense: true,
                          // contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                          title: Text(
                            alertProvider.search[index],
                            style: TextStyle(
                                fontFamily: 'Niramit Regular',
                                color: AppColors.onboard),
                          ),
                          trailing: alertProvider.isClick == index
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: SvgPicture.asset(
                                'assets/images/svgs/radioCheck.svg'),
                          )
                              : SizedBox(
                            height: 20,
                            width: 20,
                            child: SvgPicture.asset(
                                'assets/images/svgs/radioUnchecked.svg'),
                          ),
                        ),
                        if (index != alertProvider.search.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Divider(),
                          ),
                      ],
                    );
                  }),
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
                        onTap: (){
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
                        onTap: (){
                          Navigator.pop(context);
                          alertProvider.saveSearch(alertProvider.check);

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
               ),
       )),
    );
  }
}

