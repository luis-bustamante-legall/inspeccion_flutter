import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/models/inspection_schedule_model.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:legall_rimac_virtual/widgets/chat_button.dart';
import 'package:legall_rimac_virtual/widgets/phone_call_button.dart';

class InspectionStep4Screen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => InspectionStep4ScreenState();
}

class InspectionStep4ScreenState extends State<InspectionStep4Screen> {
  final _textController = TextEditingController();
  InspectionBloc _inspectionBloc;

  @override
  void initState() {
    super.initState();
    _inspectionBloc = BlocProvider.of<InspectionBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(_l.translate('inspection step',arguments: {"step": "4" })),
          actions: [
            PhoneCallButton(),
            ChatButton()
          ],
        ),
        body: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Text(_l.translate('additional info')),
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.all(5),
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1
                  )
                ),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: 500,
                  maxLengthEnforced: true,
                  decoration: InputDecoration(
                      border: InputBorder.none
                  ),
                  controller: _textController,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: BlocListener<InspectionBloc,InspectionState>(
                  listener: (context,state) {
                    if (state is InspectionUpdated) {
                      if (state.success) {
                        Navigator.pushReplacementNamed(context, AppRoutes.inspectionComplete, arguments: state.inspectionModel);
                      } else {
                        Future.delayed(Duration(milliseconds: 100),() {
                          var messenger = Scaffold.of(context);
                          messenger.hideCurrentSnackBar();
                          messenger.showSnackBar(SnackBar(
                            duration: Duration(seconds: 4),
                            backgroundColor: Colors.red,
                            content: ListTile(
                              leading: Icon(Icons.announcement_rounded),
                              title: Text(_l.translate('problems finish inspection'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ));
                        });
                      }
                    }
                  },
                  child: RaisedButton(
                    child: Text(_l.translate('finish inspection').toUpperCase(),
                        style: _t.accentTextTheme.button
                    ),
                    color: _t.accentColor,
                    onPressed: () {
                      var currentState = _inspectionBloc.state;
                      if (currentState is InspectionLoaded) {
                        var newInspection = currentState.inspectionModel.copyWith(
                          additionalInfo: _textController.text,
                          status: InspectionStatus.complete
                        );
                        newInspection.schedule.forEach((sch) {
                          if (sch.type == InspectionScheduleType.scheduled) {
                            sch.type = InspectionScheduleType.complete;
                          }
                        });
                        _inspectionBloc.add(UpdateInspectionData(
                            newInspection, UpdateInspectionType.status));
                      }
                    },
                  ),
                )
              )
            ]
        )
    );
  }
}