import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/blocs/deeplink_bloc.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/inspecciones_response.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/models/inspection_schedule_model.dart';
import 'package:legall_rimac_virtual/repositories/rest_repository.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:legall_rimac_virtual/widgets/inspection_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  AppLocalizations _l;
  DeepLinkBloc _deepLinkBloc;
  InspectionBloc _inspectionBloc;
  RestRepository _restRepository;
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => sharedPreferences=value);
    _restRepository = RestRepository();
    _deepLinkBloc = BlocProvider.of<DeepLinkBloc>(context);
    _inspectionBloc = BlocProvider.of<InspectionBloc>(context);
    _deepLinkBloc.add(CaptureDeepLink());
  }

  @override
  Widget build(BuildContext context) {
    final _inspectionCollection =
        FirebaseFirestore.instance.collection('inspections');
    _l = AppLocalizations.of(context);
    return BlocListener<DeepLinkBloc, DeepLinkState>(
        listener: (context, state) {
      print(state);
      if (state is DeepLinkInvalid) {
        var messenger = Scaffold.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          content: Text(
            _l.translate('capture link invalid'),
            overflow: TextOverflow.ellipsis,
          ),
        ));
      } else if (state is DeepLinkCaptured) {
        _inspectionBloc.updateInspection();
      }
    }, child: BlocBuilder<InspectionBloc, InspectionState>(
            builder: (context, state) {
      if (state is InspectionLoaded) {
        return Scaffold(
            appBar: AppBar(
                title: Text(state.inspectionModel.titleToShow ??
                    _l.translate('app title'))),
            floatingActionButton: Visibility(
                visible: (state?.inspectionModel?.showLegallLogo ?? false),
                child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset('assets/images/legal-logo.png',
                            height: 70)))),
            body: StreamBuilder<QuerySnapshot<Map<String,Object>>>(
                stream: _inspectionCollection
                    .where("insured_name",
                        isEqualTo: state.inspectionModel.insuredName)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<InspectionModel> listInspeccionesFirebase = [];
                  if (snapshot.hasData) {
                    snapshot.data.docs.forEach((element) {
                      final schedule = element.data()['schedule'];
                      if(schedule!=null){
                        listInspeccionesFirebase.add(InspectionModel.fromJSON(element.data(),
                            id: element.data()["token"]));
                      }

                    });
                    return FutureBuilder<InspeccionesResponse>(
                      future: _restRepository.getInspecciones(listInspeccionesFirebase[0].insuredName),
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        if(snapshot.hasData){
                          final response = snapshot.data;
                          List<InspectionModel> listData=[];
                          final inspeccionAll = sharedPreferences.getString('inspectionIdAll') ??"";
                          response.list.forEach((elementResponse) {
                            listInspeccionesFirebase.forEach((inspFirebase) {
                              if(elementResponse.placa==inspFirebase.plate && inspeccionAll.contains(inspFirebase.inspectionId)){
                                listData.add(inspFirebase);
                              }
                            });
                          });
                          return ListView.builder(
                              itemCount: listData.length,
                              itemBuilder: (BuildContext context, int index) {
                                final inspection = listData[index];
                                final schedule = inspection.schedule.first;
                                return InspectionWidget(
                                    model: inspection,
                                    schedule: schedule,
                                    onTap: inspection.status !=
                                        InspectionStatus.complete &&
                                        (schedule.type ==
                                            InspectionScheduleType
                                                .scheduled ||
                                            schedule.type ==
                                                InspectionScheduleType
                                                    .unconfirmed)
                                        ? () {
                                      if (schedule.type ==
                                          InspectionScheduleType.scheduled) {
                                        Navigator.pushNamed(
                                            context, AppRoutes.inspection,
                                            arguments: inspection);
                                      } else {
                                        Navigator.pushNamed(context,
                                            AppRoutes.scheduleInspectionStep1,
                                            arguments: inspection);
                                      }
                                    }
                                        : null);
                              });
                        }else{
                          return Center(child: CircularProgressIndicator());
                        }

                      },
                    );
                    // children: state.inspectionModel.schedule.reversed
                    //     .map((schedule) => )
                    //     .toList());
                  } else {
                    return Container();
                  }
                }));
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    })

        // BlocBuilder<InspectionBloc,InspectionState>(
        //     builder: (context,state) {
        //       if (state is InspectionLoaded) {
        //         return Scaffold(
        //             appBar: AppBar(
        //                 title: Text(state.inspectionModel.titleToShow??_l.translate('app title'))
        //             ),
        //             floatingActionButton: Visibility(
        //                 visible: (state?.inspectionModel?.showLegallLogo??false),
        //                 child: Padding(
        //                     padding: EdgeInsets.all(15),
        //                     child: Align(
        //                         alignment: Alignment.bottomRight,
        //                         child: Image.asset('assets/images/legal-logo.png', height: 70)
        //                     )
        //                 )
        //             ),
        //             body: ListView(
        //                 children: state.inspectionModel.schedule.reversed.map((schedule) =>
        //                     InspectionWidget(
        //                         model: state.inspectionModel,
        //                         schedule: schedule,
        //                         onTap: state.inspectionModel.status != InspectionStatus.complete && (
        //                             schedule.type == InspectionScheduleType.scheduled ||
        //                                 schedule.type == InspectionScheduleType.unconfirmed
        //                         ) ? () {
        //                           if (schedule.type == InspectionScheduleType.scheduled)
        //                             Navigator.pushNamed(context, AppRoutes.inspection);
        //                           else
        //                             Navigator.pushNamed(context, AppRoutes.scheduleInspectionStep1,
        //                                 arguments: state.inspectionModel
        //                             );
        //                         }: null
        //                     )
        //                 ).toList()
        //             )
        //         );
        //       } else {
        //         return Center(
        //           child: CircularProgressIndicator(),
        //         );
        //       }
        //     }
        // )
        );
  }
}
