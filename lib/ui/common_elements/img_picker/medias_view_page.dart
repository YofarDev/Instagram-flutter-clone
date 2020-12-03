import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MediasViewPage extends StatefulWidget {
  final List<Uint8List> medias;

  MediasViewPage(this.medias);

  @override
  _MediasViewPageState createState() => _MediasViewPageState();
}

class _MediasViewPageState extends State<MediasViewPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.white,
        child: CarouselSlider(
          items: _items(),
          options: CarouselOptions(
            viewportFraction: 1.0,
            pageSnapping: false,
            enableInfiniteScroll: false,
            disableCenter: true,
          ),
        ),
      ),
    );
  }

  List<Widget> _items() => widget.medias.map((e) => Image.memory(e)).toList();
}
