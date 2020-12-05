import 'package:flutter/material.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/database/publication_services.dart';
import 'package:instagram_clone/ui/common_elements/comments_page.dart';
import 'package:instagram_clone/ui/common_elements/list_users/likes_page.dart';
import 'package:instagram_clone/ui/common_elements/video_player.dart';
import 'package:instagram_clone/ui/common_elements/content_slider.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/utils/extensions.dart';

class PublicationItem extends StatefulWidget {
  final Publication publication;
  final User currentUser;
  final bool isFeed;

  PublicationItem({
    @required this.publication,
    @required this.currentUser,
    @required this.isFeed,
  });

  @override
  _PublicationItemState createState() => _PublicationItemState();
}

class _PublicationItemState extends State<PublicationItem> {
  Publication _publication;
  User _currentUser;
  bool _liked;

  @override
  void initState() {
    super.initState();
    _publication = widget.publication;
    _currentUser = widget.currentUser;
    _liked = _getLikeState();
  }

  @override
  Widget build(BuildContext context) {
    List<Content> contentList = _getListContent(_publication.content);
    return Column(
      children: [
        _getTop(),
        Container(child: _getContent(contentList)),
        _getIconsBot(),
        _getCommentsLayout(),

        /// SEPARATOR
        Container(
          height: 20,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _getTop() {
    return GestureDetector(
      onTap: () => Utils.navToUserDetails(context, _publication.user),
      child: Container(
        color: Colors.white,
        height: 60,
        padding: EdgeInsets.only(left: 12, right: 12),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                    Utils.getProfilePic(_publication.user.picture)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _publication.user.username,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Spacer(),
            Icon(
              Icons.more_vert,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }

  Widget _getContent(List<Content> contentList) {
    if (contentList.length > 1)
      return ContentSlider(
        contentList: contentList,
        isBytes: false,
      );
    else if (contentList[0].isVideo)
      return VideoPlayerWidget(path: contentList[0].url, isFile: false);
    else
      return Image.network(
        Utils.strToItemContent(_publication.content[0]).url,
      );
  }

  Widget _getIconsBot() {
    return Container(
      color: Colors.white,
      height: 65,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      child: Row(
        children: [
          IconButton(
            icon: (_liked)
                ? Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 30,
                  )
                : Icon(
                    Icons.favorite_border_outlined,
                    size: 30,
                  ),
            onPressed: () => _updateLike(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(
                Icons.mode_comment_outlined,
                size: 30,
              ),
              onPressed: () {
                _openCommentPage();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(
                Icons.send_outlined,
                size: 30,
              ),
              onPressed: () {},
            ),
          ),
          Spacer(),
          Icon(
            Icons.bookmark_outline_sharp,
            size: 30,
          )
        ],
      ),
    );
  }

  Widget _getCommentsLayout() {
    String like;
    if (_publication.likes.length == 1)
      like = "1 like";
    else
      like = _publication.likes.length.toString() + " likes";
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_publication.likes.length > 0)
            GestureDetector(
              onTap: () => _onLikesListTap(),
              child: Text(
                like,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                _publication.user.username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    _publication.legend,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
          (_publication.commentCount != 0)
              ? Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    onTap: (() {
                      _openCommentPage();
                    }),
                    child: Text(
                      _getCommentCountStr(_publication.commentCount),
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : Container(),
          (widget.isFeed)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: CircleAvatar(
                        backgroundImage: Utils.getProfilePic(
                          widget.currentUser.picture,
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        maxLines: null,
                        autocorrect: false,
                        onChanged: (value) => setState(() {
                          // needed to update Post button
                        }),
                        onSubmitted: (value) {},
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: AppStrings.addComment,
                            contentPadding: EdgeInsets.only(left: 10)),
                      ),
                    ),
                  ],
                )
              : Container(),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              Utils.getHowLongAgoLonger(_publication.date)
                  .capitalizeFirstLetter,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _getLikeState() => _publication.likes.contains(_currentUser.id);

  void _updateLike() async {
    setState(() {
      _liked = !_liked;
    });
    if (_liked)
      _publication.likes.add(_currentUser.id);
    else
      _publication.likes.remove(_currentUser.id);

    PublicationServices.updateLike(
        _publication.user.id, _publication.id, _liked);
  }

  List<Content> _getListContent(List<String> contents) {
    List<Content> contentList = [];
    for (String c in _publication.content)
      contentList.add(Utils.strToItemContent(c));
    return contentList;
  }

  String _getLikesStr(int likes) {
    if (likes == 1)
      return "1 like";
    else if (likes > 1)
      return "$likes likes";
    else
      return "";
  }

  String _getCommentCountStr(int comments) {
    String str;
    if (comments == 1)
      str = "${AppStrings.viewComment1} $comments ${AppStrings.viewComment3}";
    else
      str =
          "${AppStrings.viewComment1} ${AppStrings.viewComment2} $comments ${AppStrings.viewComment3}s";
    return str;
  }

  void _openCommentPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return CommentsPage(
        publication: _publication,
        currentUser: _currentUser,
      );
    }));
  }

  void _onLikesListTap() => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LikesPage(_publication.likes),
        ),
      );
}
