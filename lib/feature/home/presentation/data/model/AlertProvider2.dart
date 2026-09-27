import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

class AlertProvider2 with ChangeNotifier {
  var alertBox2 = Hive.box('SettingBox');
  int isClick = 0;
  late String check = 'Google';

  List search = [
    'Google',
    'Bing',
    'Yahoo',
  ];

  void changeRadioButton(int newIndex) {
    check = search[newIndex];
    isClick = newIndex;

    notifyListeners();
  }

  void saveSearchIndex() {
    alertBox2.put('newSearch', isClick);
  }

  void saveSearch(String name) {
    alertBox2.put('search', name);
    saveSearchIndex();
    notifyListeners();
  }
}
