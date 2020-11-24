import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/media_services.dart';
import 'package:instagram_clone/services/publication_services.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/ui/pages/tab1_home/img_picker/medias_view_page.dart';
import 'package:instagram_clone/ui/pages_holder.dart';
import 'package:instagram_clone/utils/utils.dart';

class PublicationInfoPage extends StatefulWidget {
  final List<Uint8List> medias;

  PublicationInfoPage(this.medias);

  @override
  _PublicationInfoPageState createState() => _PublicationInfoPageState();
}

class _PublicationInfoPageState extends State<PublicationInfoPage> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: ListView(
        children: [
          _captionField(),
          _separator(),
        ],
      ),
    );
  }

  Widget _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          AppStrings.newPost,
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.blue,
              ),
              onPressed: () => _addNewPublication())
        ],
      );

  Widget _captionField() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MediasViewPage(widget.medias),
                ),
              ),
              child: Image.memory(
                widget.medias[0],
                width: 65,
                height: 65,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                ),
                child: TextField(
                  maxLines: null,
                  autocorrect: false,
                  controller: _textController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: AppStrings.caption,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _separator() => Container(
        height: 1,
        color: AppColors.grey1010,
      );

  void _addNewPublication() async {
    List<Content> content = [];
    for (Uint8List media in widget.medias)
      content.add(
        Content(
          false,
          await MediaServices.uploadImage(media, UserServices.currentUser),
          1,
        ),
      );

    bool uploaded = true;
    for (Content c in content) if (c.url.isEmpty) uploaded = false;

    if (uploaded) {
      List<String> contentStr = [];
      for (Content c in content) contentStr.add(Utils.itemContentToStr(c));

      Publication newPublication = Publication.newPublication(
        userId: UserServices.currentUser,
        date: DateTime.now().toString(),
        legend: _textController.text,
        content: contentStr,
      );

      await PublicationServices.addPublication(newPublication);
      // To remove all route and reload PagesHolder()
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => PagesHolder(0)),
          (Route<dynamic> route) => false);
    } else
      print("error uploading");
  }
}
