import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';

class MediaFile {
  String path;
  Uint8List thumb;
  bool isVideo;
  Uint8List bytes;
  Offset position;
  int duration;

  MediaFile({
    @required this.path,
    @required this.thumb,
    @required this.isVideo,
    this.duration,
  });
}


