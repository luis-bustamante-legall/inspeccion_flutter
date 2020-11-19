
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/data_helper.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';
import 'package:legall_rimac_virtual/routes.dart';

class SplashScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>{
  ThemeData _t;
  var _height = 0.0;



  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2),() async {
      var platform = MethodChannel('https.legall_rimac_virtual/channel');
      var _settingsRepository = RepositoryProvider.of<SettingsRepository>(context);
      var _inspectionsRepository = RepositoryProvider.of<InspectionsRepository>(context);
      setState(() {
        _height = 115.0;
      });
      String initialLink = await platform.invokeMethod('initialLink');
      if (initialLink != null && validateLink(initialLink)) {
        var token = getToken(initialLink);
        var inspection = await _inspectionsRepository.fromToken(token);
        if (inspection != null) {
          _settingsRepository.setInspectionId(inspection.inspectionId);
        }
      }
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    _t = Theme.of(context);

    return Container(
      color: Colors.white,
      child:  Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/legal-logo.png', height: 200,),
                  AnimatedContainer(
                    height: _height,
                    duration: Duration(milliseconds: 300),
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: SizedBox(
                          height: 35,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('v1.1',
                style: _t.textTheme.headline6,
              ),
            ),
          )
        ]
      ),
    );
  }
}