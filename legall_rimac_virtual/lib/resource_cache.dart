import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ResourceCache {
  Map<String, MapEntry<DateTime,Uint8List>> _resourceCache = {};

  ImageProvider get({String id, String localCache, String resourceUrl, DateTime dateTime}) {
    if (resourceUrl == null)
      return null;
    if (localCache != null) {
      var cacheFile = File(localCache);
      if (_resourceCache.containsKey(id)) {
        var cache = _resourceCache[id];
        if (dateTime.compareTo(cache.key) != 0) {
          MapEntry<DateTime,Uint8List> newCache = MapEntry(
              dateTime,
              cacheFile.readAsBytesSync());
          _resourceCache[id] = newCache;
          return MemoryImage(newCache.value);
        } else {
          return MemoryImage(cache.value);
        }
      } else {
        MapEntry<DateTime,Uint8List> newCache = MapEntry(
            dateTime,
            cacheFile.readAsBytesSync());
        _resourceCache[id] = newCache;
        return MemoryImage(newCache.value);
      }
    } else if (resourceUrl != null) {
      return NetworkImage(resourceUrl);
    }
    return null;
  }

  Image loadImageHelp(String url) {
    var res =  Uri.tryParse(url);
    if (res?.isScheme('assets') == true)
      return Image.asset('assets/default/${url.substring(9)}', fit: BoxFit.fitWidth);
    else
      return Image.network(url, fit: BoxFit.fitWidth);
  }

  Future<VideoPlayerController> loadVideoHelp(String url) async {
    var res =  Uri.tryParse(url);
    if (res?.isScheme('assets') == true)
      return VideoPlayerController.asset('assets/default/${url.substring(9)}');
    else
      return VideoPlayerController.network(url);
  }
}