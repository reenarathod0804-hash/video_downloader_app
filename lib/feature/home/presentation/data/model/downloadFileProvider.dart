import 'package:flutter/material.dart';

class FileProvider with ChangeNotifier {
  int? isClick;

  void clickEvent(int index) {
    if (isClick == index) {
      isClick = -1;
    } else {
      isClick = index;
    }
    notifyListeners();
  }
}
