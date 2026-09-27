import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class LocalizationService {
  final Locale locale;

  LocalizationService(this.locale);

  static LocalizationService of(BuildContext context) {
    return Localizations.of<LocalizationService>(context, LocalizationService)!;
  }

  late Map<String, String> _localizedStrings;

  Future<void> load() async {
    final jsonStr =
    await rootBundle.loadString("assets/lang/${locale.languageCode}.json");

    Map<String, dynamic> jsonMap = json.decode(jsonStr);
    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key) {
    return _localizedStrings[key] ?? '** $key not found';
  }

  static const supportedLocales = [
    Locale("es"),
    Locale("th"),
    Locale("en"),
    Locale("vi"),
    Locale("pt"),
    Locale("id"),

  ];

  static Locale? localeResolutionCallback(
      Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return supportedLocale;
        }
      }
    }
    return supportedLocales.first;
  }

  static const LocalizationsDelegate<LocalizationService> delegate =
  _LocalizationServiceDelegate();

  static const localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    delegate,
  ];
}

class _LocalizationServiceDelegate
    extends LocalizationsDelegate<LocalizationService> {
  const _LocalizationServiceDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'th', 'en','vi','pt','id'].contains(locale.languageCode);
  }

  @override
  Future<LocalizationService> load(Locale locale) async {
    var service = LocalizationService(locale);
    await service.load();
    return service;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}
