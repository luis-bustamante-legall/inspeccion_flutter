
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/blocs/deeplink_bloc.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/models/inspection_schedule_model.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:legall_rimac_virtual/widgets/inspection_widget.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  AppLocalizations _l;
  DeepLinkBloc _deepLinkBloc;
  InspectionBloc _inspectionBloc;
  String _homeTitle = "...";

  @override
  void initState() {
    super.initState();
    _deepLinkBloc = BlocProvider.of<DeepLinkBloc>(context);
    _inspectionBloc = BlocProvider.of<InspectionBloc>(context);
    _deepLinkBloc.add(CaptureDeepLink());
  }

  @override
  Widget build(BuildContext context) {
    _l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_homeTitle)
      ),
      body: BlocListener<DeepLinkBloc,DeepLinkState>(
        listener: (context,state) {
          print(state);
          if (state is DeepLinkInvalid) {
            var messenger = Scaffold.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(SnackBar(
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
              content: Text(_l.translate('capture link invalid'),
                overflow: TextOverflow.ellipsis,
              ),
            ));
          } else if (state is DeepLinkCaptured) {
            _inspectionBloc.updateInspection();
          }
        },
        child: BlocBuilder<InspectionBloc,InspectionState>(
          builder: (context,state) {
            if (state is InspectionLoaded) {
              Future.delayed(Duration(milliseconds: 1),(){
                setState(() {
                  _homeTitle = state.inspectionModel.titleToShow??'Rimac Virtual';
                });
              });
              var children = <Widget>[];
              children.addAll(state.inspectionModel.schedule.reversed.map((schedule) =>
                  InspectionWidget(
                      model: state.inspectionModel,
                      schedule: schedule,
                      onTap: state.inspectionModel.status != InspectionStatus.complete && (
                          schedule.type == InspectionScheduleType.scheduled ||
                          schedule.type == InspectionScheduleType.unconfirmed
                      ) ? () {
                        if (schedule.type == InspectionScheduleType.scheduled)
                          Navigator.pushNamed(context, AppRoutes.inspection);
                        else
                          Navigator.pushNamed(context, AppRoutes.scheduleInspectionStep1,
                            arguments: state.inspectionModel
                          );
                      }: null
                  )
              ));
              if (state.inspectionModel.showLegallLogo??false) {
                children.addAll([
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset('assets/images/legal-logo.png', height: 70)
                    ),
                  )
                ]);
              }
              return ListView(
                children: children
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        )
      )
    );
  }
}