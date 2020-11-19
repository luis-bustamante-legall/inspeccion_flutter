
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
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
  ThemeData _t;
  AppLocalizations _l;

  @override
  Widget build(BuildContext context) {
    _t = Theme.of(context);
    _l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_l.translate('app title')),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.scheduleInspectionStep1);
            },
          )
        ],
      ),
      body: BlocBuilder<InspectionBloc,InspectionState>(
        builder: (context,state) {
          if (state is InspectionLoaded) {
            return ListView(
                children: state.inspectionModel.schedule.map((schedule) =>
                    InspectionWidget(
                        model: state.inspectionModel,
                        schedule: schedule,
                        onTap: schedule.type == InspectionScheduleType.scheduled
                            && state.inspectionModel.status != InspectionStatus.complete?
                        () {
                          Navigator.pushNamed(context, AppRoutes.inspection);
                        }: null
                    )
                ).toList()
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      )
    );
  }
}