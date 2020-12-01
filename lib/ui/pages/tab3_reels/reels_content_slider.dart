import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/ui/common_elements/video_player.dart';

class ReelsContentSlider extends StatefulWidget {
  final List<Content> contentList;

  ReelsContentSlider(this.contentList);

  _ReelsContentSliderState createState() => _ReelsContentSliderState();
}

class _ReelsContentSliderState extends State<ReelsContentSlider> {
  bool _isMuted;
  bool _isIconSoundVisible;

  @override
  void initState() {
    super.initState();
    _isMuted = true;
    _isIconSoundVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = _getContentWidgetList(widget.contentList);
    return Container(
      color: Colors.black,
      child: CarouselSlider(
        items: content,
        options: CarouselOptions(
          scrollDirection: Axis.vertical,
          scrollPhysics: PageScrollPhysics(),
          aspectRatio: widget.contentList[0].aspectRatio,
          viewportFraction: 1.0,
          pageSnapping: false,
          disableCenter: true,
          enableInfiniteScroll: true,
        ),
      ),
    );
  }

  List<Widget> _getContentWidgetList(List<Content> contentList) {
    List<Widget> contentWidgets = [];
    for (Content content in contentList)
      contentWidgets.add(_buildView(
        video: VideoPlayerWidget(
            path: content.url,
            isFile: false,
            onMute: (bool isMuted) => _onTap(isMuted)),
        overlay: _overlay(),
        soundIcon: _soundIcon(_isMuted),
      ));
    return contentWidgets;
  }

  Widget _buildView(
          {VideoPlayerWidget video, Widget overlay, Widget soundIcon}) =>
      Stack(
        children: [
          Container(width: MediaQuery.of(context).size.width, child: video),
          overlay,
          soundIcon,
        ],
      );

  Widget _overlay() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Reels",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white),
                ),
                Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ],
            ),
          )
        ],
      );

  Widget _soundIcon(bool isMuted) => IgnorePointer(
        child: AnimatedOpacity(
          opacity: _isIconSoundVisible ? 1 : 0,
          duration: Duration(milliseconds: _isIconSoundVisible ? 1 : 500),
          child: Center(
            child: Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      color: AppColors.grey1040,
                      height: 80,
                      width: 80,
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    (isMuted) ? Icons.volume_mute : Icons.volume_down,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  _onTap(bool isMuted) async {
    setState(() {
      _isMuted = isMuted;
      _isIconSoundVisible = true;
    });
    Future.delayed(Duration(milliseconds: 1500)).then((value) {
      setState(() {
        _isIconSoundVisible = false;
      });
    });
  }
}
