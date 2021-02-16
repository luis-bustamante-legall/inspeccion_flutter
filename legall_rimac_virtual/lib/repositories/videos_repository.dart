import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image/image.dart' as imx;
import 'dart:io';
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

  Future<void> uploadVideo(VideoModel video,File file) async {
    var appDir = await getApplicationDocumentsDirectory();
    //Make thumbnail
    var thumbnail = imx.encodePng(
      imx.decodeImage(
        await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.PNG,
          maxWidth: 400,
          maxHeight: 400
        )
      )
    );
    var extension = file.path.split('.').last;
    await file.copy('${appDir.path}/${video.id}.$extension');
    //Upload video
    await storage.uploadFile('/videos/${video.id}_video', file, null);
    await storage.upload('/videos/${video.id}_thumb', thumbnail, null);
    //Updating Firebase
    video.resourceUrl = await storage.downloadURL('/videos/${video.id}_video');
    video.dateTime = DateTime.now();
    video.status = ResourceStatus.uploaded;
    return _videosCollection.doc(video.id)
        .update(video.toJSON());
  }
}