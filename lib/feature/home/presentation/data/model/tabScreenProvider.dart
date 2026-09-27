import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';

class TabProvider with ChangeNotifier {
  int isSelect = 0;
  MotionTabBarController? motionTabBarController;

  void select(int index) {
    motionTabBarController!.index = index;
    notifyListeners();
  }
}
