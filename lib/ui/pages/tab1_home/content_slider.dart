import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/ui/common_elements/video_player.dart';

class ContentSlider extends StatefulWidget {
  final List<Content> contentList;
  ContentSlider(this.contentList);
  _ContentSliderState createState() => _ContentSliderState();
}

class _ContentSliderState extends State<ContentSlider> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> content = _getContentWidgetList(widget.contentList);
    return Container(color: Colors.white, child: Column(children: [
      CarouselSlider(
        items: content,
        options: CarouselOptions(
            aspectRatio: double.parse(widget.contentList[0].aspectRatio),
            viewportFraction: 1.0,
            pageSnapping: false,
            disableCenter: true,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            }),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: content.map((e) {
          int index = content.indexOf(e);
          return Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
                        shape: BoxShape.circle,
              color: _current == index
                  ? Colors.cyan
                  : Color.fromRGBO(0, 0, 0, 0.4),
            ),
          );
        }).toList(),
      ),
    ]),);
  }

  _getContentWidgetList(List<Content> contentList) {
    List<Widget> contentWidgets = [];
    for (Content content in contentList)
      (content.isVideo)
          ? contentWidgets.add(VideoPlayerWidget(content.url, false))
          : contentWidgets.add(
              Image(
                image: AssetImage(content.url),
                fit: BoxFit.fitWidth,
              ),
            );

    return contentWidgets;
  }
}
