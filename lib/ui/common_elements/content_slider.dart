import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/ui/common_elements/video_player.dart';

class ContentSlider extends StatefulWidget {
  final List<Content> contentList;
  final List<Uint8List> contentBytesList;
  final bool isBytes;
  final showDots;
  final Function(int) onMediaChanged;
  final int initialPage;
  final CarouselController controller;

  ContentSlider(
      {this.contentList,
      this.contentBytesList,
      this.isBytes,
      this.showDots,
      this.onMediaChanged,
      this.initialPage,
      this.controller});

  _ContentSliderState createState() => _ContentSliderState();
}

class _ContentSliderState extends State<ContentSlider> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> content = (widget.isBytes)
        ? _getContentBytesWidgetList(widget.contentBytesList)
        : _getContentWidgetList(widget.contentList);
    return Container(
      color: Colors.white,
      child: Column(children: [
        CarouselSlider(
          items: content,
          carouselController: (widget.controller != null)
              ? widget.controller
              : CarouselController(),
          options: CarouselOptions(
              aspectRatio: 1,
              viewportFraction: 1.0,
              scrollPhysics: PageScrollPhysics(),
              pageSnapping: false,
              disableCenter: true,
              initialPage: (widget.initialPage) ?? 0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
                widget.onMediaChanged(index);
              }),
        ),
        widget.showDots
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: content.map((e) {
                  int index = content.indexOf(e);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == index
                          ? Colors.cyan
                          : Color.fromRGBO(0, 0, 0, 0.4),
                    ),
                  );
                }).toList(),
              )
            : Container(),
      ]),
    );
  }

  _getContentWidgetList(List<Content> contentList) {
    List<Widget> contentWidgets = [];
    for (Content content in contentList)
      (content.isVideo)
          ? contentWidgets.add(VideoPlayerWidget(
              path: content.url,
              isFile: false,
              onMute: (bool isMute) {},
            ))
          : contentWidgets.add(
              Image(
                image: AssetImage(content.url),
                fit: BoxFit.fitWidth,
              ),
            );

    return contentWidgets;
  }

  _getContentBytesWidgetList(List<Uint8List> bytesList) {
    List<Widget> contentWidgets = [];
    for (Uint8List bytes in bytesList)
      contentWidgets.add(
        Image(
          image: MemoryImage(bytes),
          fit: BoxFit.fitWidth,
        ),
      );

    return contentWidgets;
  }
}
