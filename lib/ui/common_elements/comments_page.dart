import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/services/comment_service.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/utils/utils.dart';

class CommentsPage extends StatefulWidget {
  final Publication publication;
  final User currentUser;

  CommentsPage({this.publication, this.currentUser});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  GlobalKey<ScaffoldState> _key;
  Publication _publication;
  Stream _comments;
  ScrollController _scrollController;
  TextEditingController _textController;
  List<bool> _isCommentSelected = [];
  Comment _commentToDelete;
  bool _deleteMode = false;

  @override
  void initState() {
    super.initState();
    _key = GlobalKey<ScaffoldState>();
    _publication = widget.publication;
    _comments = CommentServices.getSnapshotCommentsForPublication(
        _publication.user.id, _publication.id);
    _scrollController = ScrollController();
    _textController = TextEditingController();
  }

  /// ********** UI **********
  /// SCAFFOLD & CHILDREN
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: _getAppBar(context, AppStrings.comments),
      body: GestureDetector(
        onTap: () {
          setState(() {
            if (_deleteMode)
              _isCommentSelected =
                  List.filled(_isCommentSelected.length, false);
            _deleteMode = false;
            _commentToDelete = null;
          });
        },
        child: Column(
          children: [
            (_publication.legend.isNotEmpty)
                ? _getPublicationResume(context)
                : Container(),
            _getSeparator(),
            Expanded(child: _getComments()),
            _getSeparator(),
            Align(
              child: _getTextField(),
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
    );
  }

  /// APPBAR
  Widget _getAppBar(BuildContext context, String title) => AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () => {Navigator.of(context).pop()},
        ),
        title: SizedBox(
          height: 35,
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.only(
              right: 30,
            ),
            icon: (_deleteMode)
                ? Icon(
                    Icons.delete,
                    color: Colors.blue,
                  )
                : Icon(
                    Icons.send_outlined,
                    color: Colors.black,
                  ),
            onPressed: (_deleteMode)
                ? () => _deleteComment()
                : () {
                    // Share icon
                  },
          ),
        ],
      );

  /// PUBLICATION USER FIELD
  Widget _getPublicationResume(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            child: CircleAvatar(
              backgroundImage: AssetImage(_publication.user.picture),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 14, right: 20, left: 4),
              child: _getRichTextForComment(
                _publication.user.username,
                _publication.legend,
              ),
            ),
          ),
        ],
      );

  /// COMMENTS LIST
  Widget _getComments() => StreamBuilder<QuerySnapshot>(
      stream: _comments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget();
        } else {
          return ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                Comment comment = Comment.fromMap(snapshot.data.docs[index].data());
                return _buildComment(comment, index);
              });
        }
      });

  Widget _buildComment(Comment comment, int index) => GestureDetector(
        onLongPress: () {
          if (comment.writtenById ==
                  UserServices.currentUser &&
              !_deleteMode) {
            setState(() {
              _deleteMode = true;
              _isCommentSelected[index] = true;
              _commentToDelete = comment;
            });
          }
        },
        child: Container(
          color:
              (!_isCommentSelected[index]) ? Colors.white : AppColors.blue200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                child: CircleAvatar(
                  backgroundImage:
                      AssetImage(comment.writtenByPicture),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 14, right: 20, left: 4),
                      child: _getRichTextForComment(
                       comment.writtenByUsername,
                        comment.body,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 4,
                        left: 4,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            Utils.getHowLongAgo(comment.date),
                            style: TextStyle(color: Colors.grey),
                          ),
                          (comment.likes.length > 0)
                              ? Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    _getLikesStr(comment),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: IconButton(
                    icon: (_isCommentLiked(comment))
                        ? Icon(
                            Icons.favorite,
                            size: 15,
                            color: Colors.red,
                          )
                        : Icon(
                            Icons.favorite_border_outlined,
                            size: 15,
                          ),
                    onPressed: () {
                      _likeComment(comment);
                    }),
              ),
            ],
          ),
        ),
      );

  /// COMMENT TEXT FIELD
  Widget _getTextField() {
    return TextField(
      controller: _textController,
      onSubmitted: (value) {
        if (_textController.text.isNotEmpty) _addNewComment(value);
      },
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
          suffix: FlatButton(
            child: Text(
              AppStrings.post,
              style: TextStyle(
                color: Colors.blue,
                fontWeight: (_textController.text.isNotEmpty)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            onPressed: () {
              if (_textController.text.isNotEmpty)
                _addNewComment(_textController.text);
            },
          ),
          hintText: AppStrings.addComment,
          contentPadding: EdgeInsets.only(left: 10)),
    );
  }

  /// SEPARATOR LINE
  Widget _getSeparator() => Container(
        height: 1,
        padding: EdgeInsets.only(top: 16),
        color: AppColors.grey1010,
      );

  /// TEXT COMMENT FORMAT
  Widget _getRichTextForComment(String pseudo, String comment) => RichText(
        textAlign: TextAlign.start,
        overflow: TextOverflow.clip,
        text: TextSpan(
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
                text: pseudo + " ",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: comment),
          ],
        ),
      );

  /// ********** DATA **********
  void _addNewComment(String text) async {
    // Create Comment object
    Comment newComment = Comment(
      body: text,
      date: DateTime.now().toString(),
      id:"",
      likes: [],
      writtenById: widget.currentUser.id,
      writtenByPicture: widget.currentUser.picture ,
      writtenByUsername: widget.currentUser.username,
    );

    // Add comment to database
    await CommentServices.addComment(
        _publication.user.id, _publication.id, newComment);
    FocusScope.of(context).unfocus();

    await Future.delayed(Duration(seconds: 2)).then((value) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 1,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 500));
    });
  }

  void _likeComment(Comment comment) {
    bool liked = _isCommentLiked(comment);
    CommentServices.likeComment(
        _publication.user.id, _publication.id, comment.id, !liked);
    setState(() {
      if (!liked)
        comment.likes.add(UserServices.currentUser);
      else
        comment.likes.remove(UserServices.currentUser);
    });
  }

  bool _isCommentLiked(Comment comment) =>
      comment.likes.contains(UserServices.currentUser);

  String _getLikesStr(Comment comment) {
    if (comment.likes.length == 1)
      return "1 like";
    else if (comment.likes.length > 1)
      return "${comment.likes.length} likes";
    else
      return "";
  }

  void _deleteComment() async {
    if (_commentToDelete != null) {
      // Show Snackbar "Deleting..."
      _key.currentState.showSnackBar(
        SnackBar(
          content: Text(AppStrings.deleteComment),
          behavior: SnackBarBehavior.floating,
          duration: Duration(days: 1),
        ),
      );

      // Deleting comment from DB
      await CommentServices.deleteComment(
              _publication.user.id, _publication.id, _commentToDelete.id)
          .then((value) {
        // Loading again comments and removing delete mode

        // Displaying user new snackbar
        Future.delayed(Duration(seconds: 2)).then((value) {
          _key.currentState.removeCurrentSnackBar();
          _key.currentState.showSnackBar(
            SnackBar(content: Text(AppStrings.deleteCommentDone)),
          );
          // On error
        }).catchError(() {
          setState(() {
            _deleteMode = false;
          });

          _key.currentState.removeCurrentSnackBar();
          _key.currentState.showSnackBar(
            SnackBar(content: Text(AppStrings.errorTryAgain)),
          );
        });
      });
    }
  }
}
