import 'package:flutter/material.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/constants.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/pages/tab3_reels/reels_content_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReelsPage extends StatefulWidget {
  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  double _statusBarHeight;

  @override
  void initState() {
    super.initState();
    _statusBarHeight = 0;
    _getStatusBarHeight();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: (_statusBarHeight == 0)
            ? LoadingWidget()
            : ReelsContentSlider(_getContentList()),
      ),
    );
  }

  /// DATA

  Future _getStatusBarHeight() async =>
      await SharedPreferences.getInstance().then((value) {
        setState(() {
          _statusBarHeight = value.getDouble(Constants.KEY_STATUS_BAR_HEIGHT);
        });
      });

  double _getAspectRatio() =>
  // MediaQuery.of(context).size.aspectRatio;
      MediaQuery.of(context).size.width /
      (MediaQuery.of(context).size.height -
          Constants.BOTTOM_BAR_HEIGHT -
          _statusBarHeight);

  List<Content> _getContentList() => _videoSamples()
      .map(
        (e) => Content(
          true,
          e,
          _getAspectRatio(),
        ),
      )
      .toList();

  List<String> _videoSamples() => [
        "assets/videos/tk1.mp4",
        "assets/videos/tk2.mp4",
        "assets/videos/tk3.mp4",
      ];
}
