import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_crop/image_crop.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:photo_view/photo_view.dart';

class SwitchTest extends StatefulWidget {
  @override
  _SwitchTestState createState() => _SwitchTestState();
}

class _SwitchTestState extends State<SwitchTest> {
  String value;
  PhotoViewController _controller;
  Offset pos;
  bool b;
  File imaaaage;

  @override
  void initState() {
    super.initState();
    value = "assets/images/ig4.jpg";
    b = false;
    _controller = PhotoViewController();
  }

  @override
  void dispose() {
    _controller.dispose();
    // _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.width,
            child: _getPhotoView(value),
          ),
          Container(
            color: Colors.yellow,
            child: FlatButton(
                onPressed: () => doSomething(), child: Text("Do something")),
          ),
          (b)
              ?  Image.file(imaaaage)

              : Container(),
        ],
      ),
    );
  }

  Widget _getPhotoView(String path) {
    _controller.reset();
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRect(
        child: PhotoView(
          controller: _controller,
          minScale: PhotoViewComputedScale.covered,
          maxScale: PhotoViewComputedScale.covered * 1.5,
          imageProvider: AssetImage(path),
        ),
      ),
    );
  }

  doSomething() async {
    var off = _controller.position;
    var scale = _controller.scale;
    var image = Image.asset("assets/images/ig4.jpg");
    var rect = Rect.fromCenter(
      center: off,
      width: image.width.toDouble(),
      height: image.height.toDouble(),
    );


    setState(() {
      b = !b;
    });
  }


}
