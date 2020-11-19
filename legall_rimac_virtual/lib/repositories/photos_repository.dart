import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:legall_rimac_virtual/data_helper.dart';
import 'package:legall_rimac_virtual/models/models.dart';
import 'package:legall_rimac_virtual/models/resource_model.dart';
import 'package:legall_rimac_virtual/storage/storage.dart';

class PhotosRepository {
  final _photosCollection = FirebaseFirestore.instance.collection('photos');
  final Storage storage;

  PhotosRepository({@required this.storage});

  Stream<List<PhotoModel>> get(String inspectionId, PhotoType photoType) {
    return _photosCollection
        .where('inspection_id',isEqualTo: inspectionId)
        .where('type',isEqualTo: enumToMap(photoType))
        .orderBy('group',descending: true)
        .snapshots()
        .map((docs) => docs.docs.map((doc) =>
        PhotoModel.fromJSON(doc.data(),id: doc.id)).toList());
  }

  Future<void> uploadPhoto(PhotoModel photo,Uint8List data) async {
      await storage.upload('/photos/${photo.id}.png', data, 'image/png');
      photo.resourceUrl = await storage.downloadURL('/photos/${photo.id}.png');
      photo.status = ResourceStatus.uploaded;
      return _photosCollection.doc(photo.id)
          .set(
            photo.toJSON(),
            SetOptions(merge: true)
      );
  }

  Future<String> addPhoto(PhotoModel photo) async {
    var doc = _photosCollection.add(photo.toJSON());
    return (await doc).id;
  }
}