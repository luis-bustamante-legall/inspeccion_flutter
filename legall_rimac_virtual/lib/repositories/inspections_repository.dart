import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:legall_rimac_virtual/models/models.dart';

class InspectionsRepository {
  final _inspectionCollection =
      FirebaseFirestore.instance.collection('inspections');
  final _notificationCollection =
      FirebaseFirestore.instance.collection('notification');
  final _photosCollection = FirebaseFirestore.instance.collection('photos');
  final _videosCollection = FirebaseFirestore.instance.collection('videos');

  Stream<InspectionModel> get(String inspectionId) {
    return _inspectionCollection
        // .where("insured_name",
        //     isEqualTo: "MERCURIO INDUSTRIA Y COMERCIO EDITADO")
        .where(FieldPath.documentId,isEqualTo: inspectionId)
        .snapshots()
        //.map((data) {
      .map((docs) => docs.docs.length > 0 ? InspectionModel.fromJSON(docs.docs.first.data(),id: inspectionId) : null);
      // return data.docs.length > 0
      //     ? data.docs.map((e) => InspectionModel.fromJSON(e.data(), id: inspectionId))
      //     : null;
    //});
  }

  Future<InspectionModel> fromId(String id) async {
    print("El id es $id");
    var inspections = await _inspectionCollection
        .where(FieldPath.documentId, isEqualTo: id.trim())
        .get();
    // var inspections = await _inspectionCollection
    //     .where("insured_name",isEqualTo: "MERCURIO INDUSTRIA Y COMERCIO EDITADO")
    //     .get();

    if (inspections.docs.isEmpty) {
      return null;
    } else {
      // await Future.forEach(inspections.docs, (item) async {
      //   await longFunc(item);
      // });
      //
      var doc = inspections.docs.first;
      try {
        //Load default resources
        var resDefault =
            json.decode(await rootBundle.loadString('assets/default.json'))
                as Map<String, dynamic>;

        if (resDefault.containsKey('photos')) {
          //Check for empty photos
          var photos = await _photosCollection
              .where('inspection_id', isEqualTo: doc.id)
              .limit(1)
              .get();

          if (photos.docs.isEmpty) {
            //The inspection is empty at photos add by default
            for (Map<String, dynamic> json
                in resDefault['photos'] as List<dynamic>) {
              var photo = PhotoModel.fromJSON(json);
              photo.inspectionId = doc.id;
              photo.creator = PhotoCreator.inspector;
              photo.helpText = photo.helpText ?? photo.description;
              photo.status = ResourceStatus.empty;
              photo.dateTime = DateTime.now();
              await _photosCollection.add(photo.toJSON());
            }
          }
        }

        if (resDefault.containsKey('videos')) {
          //Check for empty photos
          var videos = await _videosCollection
              .where('inspection_id', isEqualTo: doc.id)
              .limit(1)
              .get();

          if (videos.docs.isEmpty) {
            //The inspection is empty at videos add by default
            for (Map<String, dynamic> json
                in resDefault['videos'] as List<dynamic>) {
              var video = VideoModel.fromJSON(json);
              video.inspectionId = doc.id;
              video.helpText = video.helpText ?? video.description;
              video.status = ResourceStatus.empty;
              video.dateTime = DateTime.now();
              await _videosCollection.add(video.toJSON());
            }
          }
        }
      } catch (ex) {
        print(ex.toString());
      }
      return InspectionModel.fromJSON(doc.data(), id: doc.id);
    }
  }

  Future<void> updateStatus(InspectionModel inspectionModel) {
    return _inspectionCollection
        .doc(inspectionModel.inspectionId)
        .update(inspectionModel.toJSONWithUpdateStatus());
  }

  Future<void> updateData(InspectionModel inspectionModel) {
    return _inspectionCollection
        .doc(inspectionModel.inspectionId)
        .update(inspectionModel.toJSONWithInspectionData());
  }

  Future<void> updateSchedule(InspectionModel inspectionModel) {
    return _inspectionCollection
        .doc(inspectionModel.inspectionId)
        .update(inspectionModel.toJSONWithSchedule());
  }

  Future<void> updateNotification(InspectionModel inspectionModel) {
    final value=  _notificationCollection
        .doc("txW3eNPKZee8qMxQxpgz")
        //.doc(inspectionModel.inspectionId)
        .update(inspectionModel.toJSONWithNotification());
    print("El valor es ${inspectionModel.toJSONWithNotification()}  value : ${value.onError((error, stackTrace) {print("dasdadas error $error");})}");

    return value;
  }

}
