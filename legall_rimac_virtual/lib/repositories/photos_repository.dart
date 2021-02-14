import 'dart:typed_data';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:legall_rimac_virtual/data_helper.dart';
import 'package:legall_rimac_virtual/models/models.dart';
import 'package:legall_rimac_virtual/models/resource_model.dart';
import 'package:legall_rimac_virtual/storage/storage.dart';
import 'package:path_provider/path_provider.dart';

class PhotosRepository {
  final _photosCollection = FirebaseFirestore.instance.collection('photos');
  final Storage storage;

  PhotosRepository({@required this.storage});

  Stream<List<PhotoModel>> get(String inspectionId, PhotoType photoType) {
    List<String> types = [enumToMap(photoType)];
    if (photoType == PhotoType.predefined)
      types = [enumToMap(PhotoType.initial),enumToMap(PhotoType.predefined)];

    return _photosCollection
        .where('inspection_id',isEqualTo: inspectionId)
        .where('type',whereIn: types)
        .orderBy('group',descending: true)
        .snapshots()
        .map((docs) => docs.docs.map((doc) =>
        PhotoModel.fromJSON(doc.data(),id: doc.id)).toList());
  }

  Future<void> uploadPhoto(PhotoModel photo,Uint8List data) async {
      var appDir = await getApplicationDocumentsDirectory();
      //Upload image
      await storage.upload('/photos/${photo.id}', data, 'image/png');
      //Updating Firebase
      photo.resourceUrl = await storage.downloadURL('/photos/${photo.id}');
      photo.dateTime = DateTime.now();
      photo.status = ResourceStatus.uploaded;
      return _photosCollection.doc(photo.id)
          .update(photo.toJSON());
  }

  Future<String> addPhoto(PhotoModel photo) async {
    var doc = _photosCollection.add(photo.toJSON());
    return (await doc).id;
  }
}