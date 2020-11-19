import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:legall_rimac_virtual/models/models.dart';
import 'package:legall_rimac_virtual/models/resource_model.dart';
import 'package:legall_rimac_virtual/storage/storage.dart';

class VideosRepository {
  final _videosCollection = FirebaseFirestore.instance.collection('videos');
  final Storage storage;

  VideosRepository({@required this.storage});

  Stream<List<VideoModel>> get(String inspectionId) {
    return _videosCollection
        .where('inspection_id',isEqualTo: inspectionId)
        .snapshots()
        .map((docs) => docs.docs.map((doc) =>
        VideoModel.fromJSON(doc.data(),id: doc.id)).toList());
  }

  Future<void> uploadVideo(VideoModel video,Uint8List data) async {
    await storage.upload('/videos/${video.id}.mp4', data, 'video/mp4');
    video.resourceUrl = await storage.downloadURL('/videos/${video.id}.mp4');
    video.status = ResourceStatus.uploaded;
    return _videosCollection.doc(video.id)
        .set(video.toJSON(),
        SetOptions(merge: true)
    );
  }

}