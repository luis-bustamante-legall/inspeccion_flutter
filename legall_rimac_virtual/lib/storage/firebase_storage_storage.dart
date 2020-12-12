import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'storage.dart';

class FirebaseStorageStorage extends Storage {
  Future<void> upload(String path,Uint8List data,String contentType) async {
    var ref = FirebaseStorage.instance.ref(path);
    return ref.putData(data,SettableMetadata(
      contentType: contentType
    ));
  }

  Future<String> downloadURL(String path) {
    var ref = FirebaseStorage.instance.ref(path);
    return ref.getDownloadURL();
  }
}