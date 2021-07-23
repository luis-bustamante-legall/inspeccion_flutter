import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:legall_rimac_virtual/configuration.dart';
import 'package:legall_rimac_virtual/storage/storage.dart';

class AzureStorage extends Storage {
  final httpCreated = 201;
  AzureStorage() {
    //Check configuration
    for(var key in ['protocol','accountName','SASToken']) {
      if (!Configuration.azureStorageAccount.containsKey(key))
        throw Exception('Missing azure configuration "$key"');
    }
  }

  @override
  Future<String> downloadURL(String path) async {
    return _urlFromPath(path);
  }

  String _urlFromPath(String path,{String comp}) {
    var protocol = Configuration.azureStorageAccount['protocol'];
    var accountName = Configuration.azureStorageAccount['accountName'];
    var sasToken = Configuration.azureStorageAccount['SASToken'];
    if (comp == null)
      return "$protocol://$accountName.file.core.windows.net$path?$sasToken";
    else
      return "$protocol://$accountName.file.core.windows.net$path?comp=$comp&$sasToken";
  }

  @override
  Future<void> upload(String path, Uint8List data, String mimeType) async {
    var createResp = await http.put(Uri.parse(_urlFromPath(path)),
      headers: {
        'x-ms-version': '2020-02-10',
        'x-ms-type':'file',
        'x-ms-content-length': data.length.toString(),
        'x-ms-file-permission':'inherit',
        'x-ms-file-attributes':'None',
        'x-ms-file-creation-time': 'now',
        'x-ms-file-last-write-time': 'now'
      },
      body: ''
    );
    if (createResp.statusCode == httpCreated) {
      print('Uploading: $path - size: ${data.length}');
      final sliceSize = 3145728.0; //3M
      final sliceCount = (data.length / sliceSize).ceil();
      try {
        for(var index = 0; index < sliceCount; index ++) {
          var startIndex = ((index)*sliceSize).ceil();
          var endIndex = ((index+1)*sliceSize).ceil();
          if (endIndex > data.length)
              endIndex = data.length;
          var slice = data.sublist(startIndex,endIndex);
          print('range: $startIndex - ${endIndex-1} - size: ${slice.length}');
          var uploadResp = await http.put(Uri.parse(_urlFromPath(path, comp: 'range')),
            headers: {
              'x-ms-version': '2020-02-10',
              'x-ms-date': 'now',
              'x-ms-write': 'update',
              'x-ms-range': 'bytes=$startIndex-${endIndex-1}'
            },
            body: slice,
          );
          if (uploadResp.statusCode != httpCreated) {
            throw Exception('Can\'t upload the file $path\nResponse: ${uploadResp.body}');
          }
        }
      } catch(e) {
        rethrow;
      }
    } else {
      throw Exception('Can\'t create the file $path\nResponse: ${createResp.body}');
    }
  }

  Future<void> uploadFile(String path,File file,String contentType) async {
    var fileLength = await file.length();
    var createResp = await http.put(Uri.parse(_urlFromPath(path)),
        headers: {
          'x-ms-version': '2020-02-10',
          'x-ms-type':'file',
          'x-ms-content-length': fileLength.toString(),
          'x-ms-file-permission':'inherit',
          'x-ms-file-attributes':'None',
          'x-ms-file-creation-time': 'now',
          'x-ms-file-last-write-time': 'now'
        },
        body: ''
    );
    if (createResp.statusCode == httpCreated) {
      print('Uploading: $path - size: $fileLength');
      final sliceSize = 3145728.0; //3M
      final sliceCount = (fileLength / sliceSize).ceil();
      try {
        var fileStream = await file.open();
        for(var index = 0; index < sliceCount; index ++) {
          var startIndex = ((index)*sliceSize).ceil();
          var endIndex = ((index+1)*sliceSize).ceil();
          if (endIndex > fileLength)
            endIndex = fileLength;
          var slice = await fileStream.read(sliceSize.toInt());
          print('range: $startIndex - ${endIndex-1} - size: ${slice.length}');
          var uploadResp = await http.put(Uri.parse(_urlFromPath(path, comp: 'range')),
            headers: {
              'x-ms-version': '2020-02-10',
              'x-ms-date': 'now',
              'x-ms-write': 'update',
              'x-ms-range': 'bytes=$startIndex-${endIndex-1}'
            },
            body: slice,
          );
          if (uploadResp.statusCode != httpCreated) {
            throw Exception('Can\'t upload the file $path\nResponse: ${uploadResp.body}');
          }
        }
      } catch(e) {
        rethrow;
      }
    } else {
      throw Exception('Can\'t create the file $path\nResponse: ${createResp.body}');
    }
  }

}