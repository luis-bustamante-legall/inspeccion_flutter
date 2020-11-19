import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:legall_rimac_virtual/widgets/chat_button.dart';
import 'package:legall_rimac_virtual/widgets/phone_call_button.dart';

class InspectionStep4Screen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => InspectionStep4ScreenState();
}

class InspectionStep4ScreenState extends State<InspectionStep4Screen> {
  final _textController = TextEditingController();

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
                  decoration: InputDecoration(
                      border: InputBorder.none
                  ),
                  controller: _textController,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  child: Text(_l.translate('finish inspection').toUpperCase(),
                      style: _t.accentTextTheme.button
                  ),
                  color: _t.accentColor,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.inspectionComplete);
                  },
                ),
              )
            ]
        )
    );
  }
}