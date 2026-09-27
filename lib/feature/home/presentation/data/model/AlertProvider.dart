import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AlertProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  late Box alertBox;

  int? isChecked = 0;
  late String check = 'English';
  late String selectedLanguage = 'English';

  List<String> lang = [
    'English',
    'Indonesian',
    'Spanish',
    'Vietnamese',
    'Thai',
    'Portuguese'
  ];

  final Map<String, Locale> languageToLocale = {
    'English': const Locale('en'),
    'Indonesian': const Locale('id'),
    'Spanish': const Locale('es'),
    'Vietnamese': const Locale('vi'),
    'Thai': const Locale('th'),
    'Portuguese': const Locale('pt'),
  };

  void loadSavedLocale() {
    String savedLanguage = alertBox.get('language', defaultValue: 'English');
    check = savedLanguage;
    selectedLanguage = savedLanguage;

    String savedLocaleCode = alertBox.get('locale', defaultValue: 'en');
    _currentLocale = Locale(savedLocaleCode); // safe, fallback to 'en'

    isChecked = lang.indexOf(savedLanguage);
    notifyListeners();
  }

  void changeLanguage(int index) {
    selectedLanguage = lang[index];
    notifyListeners();
  }

  void saveLanguage() {
    check = selectedLanguage;
    isChecked = lang.indexOf(selectedLanguage);
    _currentLocale = languageToLocale[selectedLanguage]!;

    alertBox.put('language', check);
    alertBox.put('newLanguage', isChecked);
    alertBox.put('locale', _currentLocale.languageCode);

    notifyListeners();
  }
}
