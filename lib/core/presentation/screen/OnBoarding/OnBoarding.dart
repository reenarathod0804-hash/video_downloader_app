import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/core/constant/app_constant.dart';
import 'package:video_dloader/feature/home/presentation/data/model/onBoardScreenProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/screen/Home/tab_screen.dart';
import 'package:video_dloader/widget/CustomElevatedButton.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer<OnBoardProvider>(
        builder: (context, onBoardProvider, child) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: onBoardProvider.pageController,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              SizedBox(height: size.height * 0.1),
                              SizedBox(
                                height: size.height * 0.45,
                                child: SvgPicture.asset(onBoard[index].image,
                                    fit: BoxFit.fill),
                              ),
                              SizedBox(height: size.height * 0.03),
                              Text(
                                onBoard[index].title,
                                style: TextStyle(
                                  fontFamily: 'Niramit Bold',
                                  fontSize: 32,
                                ),
                              ),
                              SizedBox(height: size.height * 0.015),
                              Text(
                                onBoard[index].subTitle,
                                style: TextStyle(
                                  fontFamily: 'Niramit Regular',
                                  fontSize: 18,
                                  color: AppColors.onboard,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                        onPageChanged: (value) {
                          onBoardProvider.changePage(value);
                        },
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                  ],
                ),
              ),
              Positioned(
                bottom: size.height * 0.17,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onBoard.length,
                    (index) => AnimatedContainer(
                      margin: EdgeInsets.all(1),
                      height: size.height * 0.005,
                      width: index == onBoardProvider.currentIndex ? 50 : 18,
                      decoration: BoxDecoration(
                        gradient: onBoardProvider.currentIndex == index
                            ? AppColors.appGradientColor
                            : AppColors.appGradientColorNon,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      curve: Curves.easeIn,
                      duration: Duration(milliseconds: 100),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      if (onBoardProvider.currentIndex >= 2) ...{
                        CustomElevatedButton(
                          height: size.height * 0.065,
                          width: size.width * 0.7,
                          borderRadius: BorderRadius.circular(10),
                          fontSize: 18,
                          buttonText: 'GET STARTED',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TabScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: size.height * 0.045),
                      } else ...{
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TabScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  fontFamily: 'Niramit Regular',
                                  fontSize: 20,
                                  color: AppColors.onboard,
                                ),
                              ),
                            ),
                            Container(
                              height: size.height * 0.065,
                              width: size.width * 0.13,
                              decoration: BoxDecoration(
                                gradient: AppColors.appGradientColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  onBoardProvider.pageController.nextPage(
                                    duration: Duration(milliseconds: 100),
                                    curve: Curves.fastOutSlowIn,
                                  );
                                },
                                icon: Icon(Icons.arrow_forward_ios),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.045),
                      }
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
