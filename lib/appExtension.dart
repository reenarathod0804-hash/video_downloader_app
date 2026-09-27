import 'package:flutter/widgets.dart';
import 'package:video_dloader/appLocalization.dart';

extension LocalizationExtension on BuildContext {
  String t(String key) {
    return LocalizationService.of(this).translate(key);
  }
}
