import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:instagram_clone/res/color_filters.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image/image.dart' as img;
import 'package:photofilters/photofilters.dart' as pf;


class SwitchTest extends StatefulWidget {
  @override
  _SwitchTestState createState() => _SwitchTestState();
}

class _SwitchTestState extends State<SwitchTest> {
  GlobalKey _globalKey = GlobalKey();
  String value;
  ValueKey key1 = ValueKey(1);
  ValueKey key2 = ValueKey(2);
  PhotoViewController _controller;
  PhotoViewController _controller2;
  var image;

  @override
  void initState() {
    super.initState();
    value = "assets/images/ig4.jpg";
    _controller = PhotoViewController();
    _controller2 = PhotoViewController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.width,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRect(
                child: RepaintBoundary(
                  key: _globalKey,
                  child: PhotoView(
                    key: key1,
                    controller:  _controller ,
                    minScale: PhotoViewComputedScale.covered,
                    maxScale: PhotoViewComputedScale.covered * 1.5,
                    imageProvider: AssetImage(value),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.yellow,
            child: FlatButton(
                onPressed: () => doSomething(), child: Text("Do something")),
          ),
          AspectRatio(
              aspectRatio: 1,
              child: ClipRect(
                child: (image == null)
                    ? Container()
                    : PhotoView(
                        key: key2,
                        controller: _controller2,
                        minScale: PhotoViewComputedScale.covered,
                        maxScale: PhotoViewComputedScale.covered * 1.5,
                        imageProvider: MemoryImage(image),
                      ),
              )),
        ],
      ),
    );
  }



  doSomething() async {
  _getImage();
  }

  _getImage() async {
    var imgg = await _getBytes();
    var decoded = img.decodeImage(imgg);
  img.colorOffset(decoded, red:100);
    var filter = img.convolution(decoded, [
      1, 1, 1,
     1, 1, 1,
      1, 1, 1,
    ],);
    var encoded = img.encodePng(filter);
setState(() {
  image = encoded;
});
  }

  Future<Uint8List> _getBytes() async {
    RenderRepaintBoundary repaintBoundary =
    _globalKey.currentContext.findRenderObject();
    ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 1);
    ByteData byteData =
    await boxImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }
}
