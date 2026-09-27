import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/core/presentation/screen/OnBoarding/OnBoarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnBoarding(),
          ));
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
              decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            AppColors.orangeFF,
            AppColors.pinkFF,
          ])),
              child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: SvgPicture.asset('assets/images/svgs/sline.svg')),
            Positioned(
                top: 322,
                child: SvgPicture.asset('assets/images/svgs/splash.svg')),
            Positioned(
              top: 465,
              left: 65,
              child: Text(
                "VIDEO",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Positioned(
              top: 501,
              left: 109,
              child: Text('DOWNLOADER',
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: SvgPicture.asset('assets/images/svgs/sline2.svg')),
          ],
        ),
              ),
            ));
  }
}
