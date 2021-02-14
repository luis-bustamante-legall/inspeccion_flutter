import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ResourceCache {
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