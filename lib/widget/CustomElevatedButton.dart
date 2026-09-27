import 'package:flutter/material.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';

class CustomElevatedButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String? buttonText;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;
  final double? fontSize;

  const CustomElevatedButton(
      {super.key,
      this.height,
      this.width,
      this.buttonText,
      this.color,
      this.borderRadius,
      this.onTap, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(

        height: height,
        width: width,
        decoration: BoxDecoration(
         gradient: AppColors.appGradientColor,
          borderRadius: borderRadius,

        ),
        child: Center(child: Text(buttonText ?? '',style: TextStyle(fontSize: fontSize,color: Colors.white,fontFamily: 'Niramit Bold'),),),
      ),
    );
  }
}
