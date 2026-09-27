import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_dloader/appLocalization.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/feature/home/presentation/data/model/AlertProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/model/AlertProvider2.dart';
import 'package:video_dloader/feature/home/presentation/data/model/downloadFileProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/model/downloadScreenProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/model/homeScreenProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/model/onBoardScreenProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/model/progressScreenProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/model/settingProvider.dart';
import 'package:video_dloader/feature/home/presentation/data/model/tabScreenProvider.dart';

import 'feature/home/presentation/data/screen/Home/tab_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  AlertProvider? _alertProvider;
  Object? _startupError;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Hive.initFlutter().timeout(const Duration(seconds: 15));
      await Hive.openBox('DownloadBox').timeout(const Duration(seconds: 15));
      final settingBox =
          await Hive.openBox('SettingBox').timeout(const Duration(seconds: 15));

      final alertProvider = AlertProvider()..alertBox = settingBox;
      alertProvider.loadSavedLocale();

      if (mounted) {
        setState(() => _alertProvider = alertProvider);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _startupError = error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = _alertProvider;
    if (alertProvider != null) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AlertProvider>.value(value: alertProvider),
          ChangeNotifierProvider(create: (_) => OnBoardProvider()),
          ChangeNotifierProvider(create: (_) => TabProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => DownloadProvider()),
          ChangeNotifierProvider(create: (_) => FileProvider()),
          ChangeNotifierProvider(create: (_) => AlertProvider2()),
          ChangeNotifierProvider(create: (_) => SettingProvider()),
          ChangeNotifierProvider(create: (_) => ProgressScreenProvider()),
        ],
        child: const MyApp(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _startupError == null
                ? const CircularProgressIndicator()
                : Text(
                    'App startup failed:\n$_startupError',
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AlertProvider>().currentLocale;
    Size size = MediaQuery.of(context).size;

    return MaterialApp(
      locale: locale,
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: LocalizationService.localizationsDelegates,
      localeResolutionCallback: LocalizationService.localeResolutionCallback,
      debugShowCheckedModeBanner: false,
      title: 'video downloader',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          surfaceTintColor: Colors.white,
          toolbarHeight: size.height * 0.1,
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: 'Niramit Bold',
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
              fontFamily: 'League Spartan-Bold',
              fontSize: 32,
              color: Colors.white),
          titleMedium: TextStyle(fontFamily: 'Niramit Bold', fontSize: 21),
          labelMedium: TextStyle(fontFamily: 'Niramit Bold', fontSize: 16),
          labelSmall: TextStyle(
              fontFamily: 'Niramit Regular',
              fontSize: 14,
              color: AppColors.onboard),
          bodySmall: TextStyle(
              fontSize: 14,
              fontFamily: 'Niramit Regular',
              color: AppColors.onboard),
          titleSmall: TextStyle(fontFamily: 'Niramit Bold', fontSize: 20),
        ),
      ),
      home: const TabScreen(),
    );
  }
}
