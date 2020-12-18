import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:intl/intl.dart';

import '../brand_search_delegate.dart';
import '../model_search_delegate.dart';
import '../routes.dart';

class ScheduleInspectionStep1 extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => ScheduleInspectionStep1State();
}

class ScheduleInspectionStep1State extends State<ScheduleInspectionStep1> {
  InspectionBloc _inspectionBloc;

  @override
  void initState() {
    super.initState();
    _inspectionBloc = BlocProvider.of<InspectionBloc>(context);
  }

  Future<String> _showTextDialog({String title,String label,int maxLength,int maxLines, String Function(String) validator}) async {
    AppLocalizations _l = AppLocalizations.of(context);
    TextEditingController textController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: textController,
                  maxLength: maxLength,
                  maxLengthEnforced: true,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: label,
                  ),
                  validator: validator ?? (newText) =>
                    newText.trim().isEmpty ? _l.translate('required field'):
                    newText.length > (maxLength??1024) ? _l.translate('too long'): null
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(_l.translate('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(_l.translate('save')),
              onPressed: () {
                if (formKey.currentState.validate()) {
                  Navigator.of(context).pop(
                      textController.text
                  );
                }
              },
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_l.translate('scheduled inspection step',arguments:  { "step": "1" })),
      ),
      body: BlocBuilder<InspectionBloc,InspectionState>(
        builder: (context,state) {
          if (state is InspectionLoaded) {
            return ListView(
              padding: EdgeInsets.all(20),
              children: [
                Text(_l.translate('scheduled inspection greeting',arguments: {
                  'insured_company': state.inspectionModel?.insuranceCompany??'Rimac Virtual'
                })),
                SizedBox(height: 20,),
                Text(_l.translate('plate').toUpperCase(),
                  textAlign: TextAlign.center,
                  style: _t.textTheme.caption,
                ),
                Text(state.inspectionModel?.plate??'',
                  style: _t.textTheme.headline4.copyWith(
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        child: Text(_l.translate('insured data'),
                          style: _t.textTheme.subtitle1,
                        ),
                        padding: EdgeInsets.all(15),
                      ),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                                title: Text(_l.translate('name')),
                                subtitle: Text(state.inspectionModel?.insuredName??'-')
                            ),
                            Divider(indent: 15,endIndent: 15,height: 2,),
                            ListTile(
                                title: Text(_l.translate('contractor')),
                                subtitle: Text(state.inspectionModel?.contractorName??'-')
                            ),
                            Divider(indent: 15,endIndent: 15,height: 1,),
                            ListTile(
                                title: Text(_l.translate('contact details')),
                                subtitle: Text(state.inspectionModel?.contactPhone??'-')
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        child: Text(_l.translate('vehicle data'),
                          style: _t.textTheme.subtitle1,
                        ),
                        padding: EdgeInsets.all(15),
                      ),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(_l.translate('brand')),
                              subtitle: Text(state.inspectionModel?.brandName??'-'),
                              trailing: Icon(Icons.navigate_next,
                                  size: 35
                              ),
                              onTap: () async {
                                var brandModel = await showSearch(
                                    context: context,
                                    delegate: BrandSearchDelegate(BlocProvider.of<BrandBloc>(context))
                                );
                                if (brandModel != null) {
                                  var inspectionModel = state.inspectionModel.copyWith(
                                    brandId: brandModel.id,
                                    brandName: brandModel.brandName
                                  );
                                  _inspectionBloc.add(UpdateInspectionData(
                                      inspectionModel,
                                      UpdateInspectionType.data));
                                }
                              },
                            ),
                            Divider(indent: 15,endIndent: 15,height: 2,),
                            ListTile(
                              title: Text(_l.translate('model')),
                              subtitle: Text(state.inspectionModel?.modelName??'-'),
                              trailing: Icon(Icons.navigate_next,
                                  size: 35
                              ),
                              onTap: () async {
                                if ((state.inspectionModel.brandId??'').isEmpty)
                                  return;
                                var modelName = await showSearch(
                                    context: context,
                                    delegate: ModelSearchDelegate(
                                        BlocProvider.of<BrandBloc>(context),
                                        state.inspectionModel.brandId)
                                );
                                if (modelName != null) {
                                  var inspectionModel = state.inspectionModel.copyWith(
                                      modelName: modelName
                                  );
                                  _inspectionBloc.add(UpdateInspectionData(
                                      inspectionModel,
                                      UpdateInspectionType.data));
                                }
                              },
                            ),
                            Divider(indent: 15,endIndent: 15,height: 1,),
                            ListTile(
                              title: Text(_l.translate('contact address')),
                              subtitle: Text(state.inspectionModel?.contactAddress??'-'),
                              trailing: Icon(Icons.navigate_next,
                                  size: 35
                              ),
                              onTap: () async {
                                var contactAddress = await _showTextDialog(
                                  title: _l.translate('contact address'),
                                  label: _l.translate('contact address'),
                                  maxLength: 200
                                );
                                if (contactAddress != null) {
                                  var inspectionModel = state.inspectionModel
                                      .copyWith(
                                      contactAddress: contactAddress
                                  );
                                  _inspectionBloc.add(UpdateInspectionData(
                                      inspectionModel,
                                      UpdateInspectionType.data));
                                }
                              },
                            ),
                            Divider(indent: 15,endIndent: 15,height: 1,),
                            ListTile(
                              title: Text(_l.translate('contact email')),
                              subtitle: Text(state.inspectionModel?.contactEmail??'-'),
                              trailing: Icon(Icons.navigate_next,
                                  size: 35
                              ),
                              onTap: () async {
                                var contactEmail = await _showTextDialog(
                                    title: _l.translate('contact email'),
                                    label: _l.translate('contact email'),
                                    maxLength: 100,
                                    validator: (newEmail) {
                                      var emailRegEx = RegExp("^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-\\/=?^_`{|}~]+@[a-zA-Z0-9]+\\.[a-zA-Z]+");
                                      if(!emailRegEx.hasMatch(newEmail))
                                        return _l.translate('invalid email');
                                      return null;
                                    }
                                );
                                if (contactEmail != null) {
                                  var inspectionModel = state.inspectionModel
                                      .copyWith(
                                      contactEmail: contactEmail
                                  );
                                  _inspectionBloc.add(UpdateInspectionData(
                                      inspectionModel,
                                      UpdateInspectionType.data));
                                }
                              },
                            ),
                            Divider(indent: 15,endIndent: 15,height: 1,),
                            ListTile(
                              title: Text(_l.translate('contact phone')),
                              subtitle: Text(state.inspectionModel?.contactPhone??'-'),
                              trailing: Icon(Icons.navigate_next,
                                  size: 35
                              ),
                              onTap: () async {
                                var contactPhone = await _showTextDialog(
                                    title: _l.translate('contact phone'),
                                    label: _l.translate('contact phone'),
                                    maxLength: 15,
                                    validator: (newPhone) {
                                      var phoneRegEx = RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
                                      if(!phoneRegEx.hasMatch(newPhone))
                                        return _l.translate('invalid phone');
                                      return null;
                                    }
                                );
                                if (contactPhone != null) {
                                  var inspectionModel = state.inspectionModel
                                      .copyWith(
                                      contactPhone: contactPhone
                                  );
                                  _inspectionBloc.add(UpdateInspectionData(
                                      inspectionModel,
                                      UpdateInspectionType.data));
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      Align(
                        alignment: Alignment.centerRight,
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.scheduleInspectionStep2);
                          },
                          color: _t.accentColor,
                          child: Text(_l.translate('confirm data').toUpperCase(),
                            style: _t.accentTextTheme.button,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          } else {
            print(state);
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      )
    );
  }
}