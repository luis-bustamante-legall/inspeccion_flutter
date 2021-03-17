import 'dart:async';
import 'dart:io';
import 'package:file_lumberdash/file_lumberdash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:legall_rimac_virtual/app_theme_data.dart';
import 'package:legall_rimac_virtual/blocs/app_bloc_delegate.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/repositories.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:path_provider/path_provider.dart';
import 'package:print_lumberdash/print_lumberdash.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  var appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  final currentDate = DateTime.now();
  //Logging
  BlocSupervisor.delegate = AppBlocDelegate();
  putLumberdashToWork(withClients: [
    PrintLumberdash(),
    FileLumberdash(
      filePath: '$appDocPath/${currentDate.year}-${currentDate.month}-${currentDate.day}-logs.txt',
    )
  ]);
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (await FirebaseCrashlytics.instance.checkForUnsentReports()) {
    await FirebaseCrashlytics.instance.sendUnsentReports();
  }
  Function originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    // Forward to original handler.
    originalOnError(errorDetails);
  };
  runZonedGuarded(() {
    runApp(MultiRepositoryProvider(
        providers: getRepositoryProviders(preferences),
        child:  LegallRimacVirtualApp()));
  }, (error, stackTrace) {
    print('Crashlytics record generated.');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class LegallRimacVirtualApp extends StatefulWidget  {
  @override
  State<StatefulWidget> createState() => LegallRimacVirtualAppState();
}

class LegallRimacVirtualAppState extends State<LegallRimacVirtualApp> {
  ThemeData _theme = themeData;

  updatePrimaryTheme(Color color) {
    setState(() {
      _theme = _theme.copyWith(
        primaryColor: color,
        accentColor: color
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    //portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      theme: _theme,
      supportedLocales: [Locale('es', '')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      builder: (context, child) =>
        MediaQuery(data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: false
        ), child: child),
      routes: routes,
      initialRoute: AppRoutes.splash,
    );
  }

}
