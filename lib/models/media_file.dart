import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'dart:ui';

class MediaFile {
  String path;
  Uint8List thumb;
  bool isVideo;
  int width;
  int height;
  Offset offset;
  double scale;

  int duration;

  MediaFile({
    @required this.path,
    @required this.thumb,
    @required this.isVideo,
    this.width,
    this.height,
    this.duration,
    this.offset,
  });
}
