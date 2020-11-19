import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:legall_rimac_virtual/app_theme_data.dart';
import 'package:legall_rimac_virtual/data_helper.dart';
import 'package:legall_rimac_virtual/repositories.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  //TODO: For test only
  if (!preferences.containsKey('inspectionId')) {
    preferences.setString('inspectionId', '3f3Xh6Wtw2cYuhyzTrbJ');
  }
  runApp(MultiRepositoryProvider(
      providers: getRepositoryProviders(preferences),
      child:  LegallRimacVirtualApp()));
}

class LegallRimacVirtualApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      supportedLocales: [Locale('es', '')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      routes: routes,
      initialRoute: AppRoutes.splash,
    );
  }

}
