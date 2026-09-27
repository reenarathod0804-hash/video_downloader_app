import 'package:flutter/material.dart';

class ProgressScreenProvider with ChangeNotifier {
  int currentIndex = 0;

  void onChange(int index) {
    currentIndex = currentIndex == index ? -1 : index;
    notifyListeners();
  }
}
