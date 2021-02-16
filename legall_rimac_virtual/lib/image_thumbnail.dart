import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;

class ImageThumbnail {
  static Future<File> make(File file) async {
    var receivePort = ReceivePort();
    var isolate = await Isolate.spawn(_isolateMakeThumb, receivePort.sendPort);
    await for (var msg in receivePort) {
      if (msg == null) {
        isolate.kill(priority: Isolate.immediate);
        receivePort.close();
        throw Exception('Can\'t create the thumbnail');
      } else if (msg is SendPort) {
        msg.send(file.path);
      } else if (msg is String) {
        receivePort.close();
        isolate.kill(priority: Isolate.immediate);
        return File(msg);
      }
    }
    return null;
  }

  static void _isolateMakeThumb(SendPort sendPort) async {
    var receivePort = ReceivePort();
    try {
      sendPort.send(receivePort.sendPort);
      var path = (await receivePort.first) as String;
      var file = File(path);
      var decodeImg = img.decodeImage(await file.readAsBytes());
      var resizeImage = img.copyResizeCropSquare(decodeImg, 200);
      decodeImg = null;
      var thumbnailFile = File('${file.path}_thumb');
      if (!await thumbnailFile.exists())
        thumbnailFile.create(recursive: true);
      await thumbnailFile.writeAsBytes(img.encodePng(resizeImage));
      resizeImage = null;
      receivePort.close();
      sendPort.send(thumbnailFile.path);
    } catch(e) {
      receivePort.close();
      sendPort.send(null);
    }
  }

  static String getUrl(String resourceUrl) {
    if (resourceUrl.contains('_full?'))
      return resourceUrl.replaceFirst('_full?','_thumb?');
    else
      return resourceUrl;
  }
}