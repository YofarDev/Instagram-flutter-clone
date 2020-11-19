import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class MediaFile {
  String path;
  Uint8List thumb;
  bool isVideo;
  int duration;

  MediaFile(
      {@required this.path,
      @required this.thumb,
      @required this.isVideo,
      this.duration});
}
