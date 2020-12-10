
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/deeplink_bloc.dart';
import 'package:legall_rimac_virtual/data_helper.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/models/inspection_schedule_model.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';
import 'package:legall_rimac_virtual/routes.dart';

class SplashScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>{
  var _height = 115.0;
  DeepLinkBloc _deepLinkBloc;

  @override
  void initState() {
    super.initState();
    _deepLinkBloc = BlocProvider.of<DeepLinkBloc>(context);
    _deepLinkBloc.add(CaptureDeepLink());
  }

  void _ready(InspectionModel inspectionModel) {
    if (inspectionModel.schedule.isEmpty || inspectionModel.schedule.first.type == InspectionScheduleType.unconfirmed) {
      Navigator.pushReplacementNamed(context, AppRoutes.scheduleInspectionStep1,
        arguments: inspectionModel
      );
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
      child: BlocListener<DeepLinkBloc,DeepLinkState>(
        listener: (context,state) {
          if (state is DeepLinkCaptured) {
            _ready(state.inspectionModel);
          } else if (state is DeepLinkInitial) {
            _ready(state.inspectionModel);
          } else if (state is DeepLinkEmpty || state is DeepLinkInvalid) {
            var isInvalid = state is DeepLinkInvalid;
            showDialog(
              context: context,
              barrierDismissible: false,
              child: AlertDialog(
                title: Text(_l.translate(isInvalid ?'invalid link': 'empty link')),
                content: Text(_l.translate('no valid link available')),
                actions: [
                  FlatButton(
                    onPressed: () {
                      exit(0);
                    },
                    child: Text(_l.translate('close app'))
                  ),
                ],
              )
            );
          }
        },
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
      ),
    );
  }
}