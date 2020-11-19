import 'package:flutter/material.dart';
import 'package:instagram_clone/database/publication_services.dart';
import 'package:instagram_clone/database/user_services.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/ui/common_elements/comments_page.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/pages/tab1_home/content_slider.dart';
import 'package:instagram_clone/ui/common_elements/video_player.dart';
import 'package:instagram_clone/utils/utils.dart';

class PostItem extends StatefulWidget {
  final Publication publication;
  PostItem(this.publication,);
 
  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  Publication publication;
 List<Comment> comments = [];
  bool liked;

  @override
  void initState() {
    super.initState();
    publication = widget.publication;
    comments = widget.publication.comments;
    liked = _getLikeState();
  }

  @override
  Widget build(BuildContext context) {
    List<Content> contentList = _getListContent(publication.content);
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
  

  _getListContent(List<String> contents) {
    List<Content> contentList = [];
    for (String c in publication.content)
      contentList.add(Utils.strToContent(c));
    return contentList;
  }

  _getTop() {
    return Container(
      color: Colors.white,
      height: 60,
      padding: EdgeInsets.only(left: 12, right: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(publication.user.picture),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              publication.user.pseudo,
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
    );
  }

  Widget _getContent(List<Content> contentList) {
    if (contentList.length > 1)
      return ContentSlider(contentList);
    else if (contentList[0].isVideo)
      return VideoPlayerWidget(contentList[0].url, false);
    else
      return Image(
        image: AssetImage(
          Utils.strToContent(publication.content[0]).url,
        ),
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
            icon: (liked)
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
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return CommentsPage(publication);
                }));
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
    if (publication.likes.length == 1)
      like = "1 like";
    else
      like = publication.likes.length.toString() + " likes";
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (publication.likes.length > 0)
            Text(
              like,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                publication.user.pseudo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  publication.legend,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              )),
            ],
          ),
          (comments.isNotEmpty)
              ? Text(comments[0].comment)
              : Container(),
        ],
      ),
    );
  }

  bool _getLikeState() =>
      publication.likes.contains(UserServices.currentUser);

  void _updateLike() async {
    setState(() {
      liked = !liked;
    });
    if (liked)
      publication.likes.add(UserServices.currentUser);
    else
      publication.likes.remove(UserServices.currentUser);

    PublicationServices.updateLike(publication.user.id, publication.id, liked);
  }

  
}
