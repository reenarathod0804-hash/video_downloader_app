import 'dart:ui';

import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color orangeFF = Color(0xffFF876E);
  static const Color tomato = Color(0xffFE6A78);
  static const Color pinkFF = Color(0xffFF4785);
  static const Color onboard = Color(0xff767676);
  static const Color indicator = Color(0xffD9D9D9);
  static const Color textField = Color(0xffE9E9E9);
  static const Color lightPink=Color(0xffFE6A78);
  static const Color switchColor=Color(0xffFFD6D9);
  static const Color switchIndicator=Color(0xff9F9F9F);
  static const Color borderColor=Color(0xff00000040);
  static const Color timerColor=Color(0xffFFFFFF66);
  static const Color red00=Color(0xffFF0000);
  static Color midpointColor = Color.lerp(AppColors.orangeFF,AppColors.pinkFF, 0.5)!;

  static LinearGradient appGradientColor = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.orangeFF, AppColors.pinkFF]);
  static LinearGradient appGradientColorNon =
      LinearGradient(colors: [AppColors.indicator, AppColors.indicator]);
}
