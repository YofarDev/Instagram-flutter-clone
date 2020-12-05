import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/common_elements/add_publication/medias_view_page.dart';
import 'package:instagram_clone/ui/common_elements/add_publication/tag_people_page.dart';

class PublicationInfoPage extends StatefulWidget {
  final List<Uint8List> medias;

  PublicationInfoPage(this.medias);

  @override
  _PublicationInfoPageState createState() => _PublicationInfoPageState();
}

class _PublicationInfoPageState extends State<PublicationInfoPage> {
  TextEditingController _textController;
  List<Content> _mediasContent;
  String _tag;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _mediasContent = _getContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: ListView(
        children: [
          _captionField(),
          _separator(),
          _getField(
            hint: AppStrings.tagPeople,
            page: TagPeoplePage(_mediasContent),
            index: 0,
            suffix: _tag,
          ),
          _separator(),
          _getField(
            hint: AppStrings.addLocation,
            page: Container(),
            index: 1,
          ),
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

  Widget _getField({String hint, Widget page, int index, String suffix}) =>
      GestureDetector(
        onTap: () => _onFieldTap(page, index),
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
              hintText: hint,
              contentPadding: EdgeInsets.all(20),
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.black,
              ),
              suffixIcon: (suffix != null)
                  ? Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SizedBox(
                        width: 80,
                        child: Center(
                          child: Text(
                            suffix,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    )
                  : null),
        ),
      );

  Widget _separator() => Container(
        height: 1,
        color: AppColors.grey1010,
      );

  void _onFieldTap(Widget page, int index) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => page,
          ),
        )
        .then((value) => _handleResults(index, value));
  }

  void _addNewPublication() async {}

  List<Content> _getContent() =>
      widget.medias.map((e) => Content(bytes: e, mentions: [])).toList();

  void _handleResults(int index, var value) {
    switch (index) {
      case 0:
        {
          if (value != null) {
            _mediasContent = value;
            setState(() {
              _tag = _getTagStr();
            });
          }
        }
        break;
      default:
        {}
    }
  }

  String _getTagStr() {
    List<String> mentions = [];

    for (Content c in _mediasContent)
      mentions.addAll(c.mentions.map((e) => e.username).toList());

    Set<String> mentionsUnique = mentions.toSet();
    int count = mentionsUnique.length;

    if (count == 0)
      return null;
    else if (count == 1)
      return "@${mentionsUnique.first}";
    else
      return "$count ${AppStrings.people}";
  }
}
