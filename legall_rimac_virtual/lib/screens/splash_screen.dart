import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/deeplink_bloc.dart';
import 'package:legall_rimac_virtual/data_helper.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/main.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/models/inspection_schedule_model.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';
import 'package:legall_rimac_virtual/routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  var _height = 115.0;
  DeepLinkBloc _deepLinkBloc;

  @override
  void initState() {
    super.initState();
    _deepLinkBloc = BlocProvider.of<DeepLinkBloc>(context);
    _deepLinkBloc.add(CaptureDeepLink());
  }

  void _ready(InspectionModel inspectionModel) {
    if (inspectionModel.appColor != null) {
      Color selectedColor = Colors.indigo;
      RegExp hexColor = RegExp(r'^([0-9a-fA-F]{6})$');
      if (hexColor.hasMatch(inspectionModel.appColor)) {
        var rgb = [
          inspectionModel.appColor.substring(0, 2),
          inspectionModel.appColor.substring(2, 4),
          inspectionModel.appColor.substring(4, 6)
        ].map((hex) => int.parse(hex, radix: 16)).toList();
        selectedColor = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
      }
      var state = context.findAncestorStateOfType<LegallRimacVirtualAppState>();
      state.updatePrimaryTheme(selectedColor);
    }
    if (inspectionModel.schedule.isEmpty ||
        inspectionModel.schedule.first.type ==
            InspectionScheduleType.unconfirmed) {
      Navigator.pushReplacementNamed(context, AppRoutes.scheduleInspectionStep1,
          arguments: inspectionModel);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);

    return Container(
      color: Colors.white,
      child: BlocListener<DeepLinkBloc, DeepLinkState>(
        listener: (context, state) {
          if (state is DeepLinkCaptured) {
            _ready(state.inspectionModel);
          } else if (state is DeepLinkInitial) {
            _ready(state.inspectionModel);
            _ready(state.inspectionModel);
          } else if (state is DeepLinkEmpty || state is DeepLinkInvalid) {
            var isInvalid = state is DeepLinkInvalid;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                      _l.translate(isInvalid ? 'invalid link' : 'empty link')),
                  content: Text(_l.translate('no valid link available')),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          exit(0);
                        },
                        child: Text(_l.translate('close app'))),
                  ],
                );
              },
            );
          }
        },
        child: Column(children: [
          Expanded(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/legal-logo.png',
                    height: 200,
                  ),
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
              child: Text(
                'v1.1',
                style: _t.textTheme.headline6,
              ),
            ),
          )
        ]),
      ),
    );
  }
}
