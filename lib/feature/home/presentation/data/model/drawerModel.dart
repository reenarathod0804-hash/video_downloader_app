import 'package:flutter/cupertino.dart';

class DrawerModel {
  final String image;
  final String titleKey;
  final String filledImage;
  final Widget? screen;
  final VoidCallback? onTap;

  DrawerModel( {
    required this.image,
    required this.titleKey,  // Updated to `titleKey`
    required this.filledImage,
    this.screen,
    this.onTap,
  });
}
