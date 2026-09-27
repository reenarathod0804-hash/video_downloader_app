import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class SettingProvider with ChangeNotifier {

var settingBox=Hive.box('SettingBox');
  bool isWifi = true;

  void changeValue(bool value){
    isWifi=value;
    settingBox.put('newValue', isWifi);
    notifyListeners();
  }

}
