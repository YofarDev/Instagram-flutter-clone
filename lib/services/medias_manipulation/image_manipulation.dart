import 'dart:typed_data';
import 'dart:ui' as ui;


class ImageManipulation {

  static Future<Uint8List> getViewAsBytes({var repaintBoundary}) async {
    ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 1.0);
    ByteData byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }


}
