import 'dart:io';
import 'dart:typed_data';

abstract class Storage {
  Future<void> upload(String path,Uint8List data,String mimeType);
  Future<void> uploadFile(String path,File file, String mimeType);
  Future<String> downloadURL(String path);
}