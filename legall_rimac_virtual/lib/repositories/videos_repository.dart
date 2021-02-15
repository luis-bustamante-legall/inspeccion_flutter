import 'dart:typed_data';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:legall_rimac_virtual/models/models.dart';
import 'package:legall_rimac_virtual/models/resource_model.dart';
import 'package:legall_rimac_virtual/storage/storage.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> uploadVideo(VideoModel video,File file) async {
    var appDir = await getApplicationDocumentsDirectory();
    //Upload video
    await storage.uploadFile('/videos/${video.id}.mp4', file, 'video/mp4');
    //Cache file
    var cacheFile = File('${appDir.path}/${video.id}.mp4');
    if (! await cacheFile.exists())
      await cacheFile.create(recursive: true);
    await file.copy(cacheFile.path);
    //Updating Firebase
    video.resourceUrl = await storage.downloadURL('/videos/${video.id}.mp4');
    video.status = ResourceStatus.uploaded;
    return _videosCollection.doc(video.id)
        .update(video.toJSON());
  }

}