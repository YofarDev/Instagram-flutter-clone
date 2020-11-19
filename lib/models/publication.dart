import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/user.dart';

class Publication {
  String id;
  User user;
  String date;
  List<String> content;
  String legend;
  List<String> likes = [];
  List<Comment> comments = [];

  Publication(
    this.date,
    this.content,
    this.legend,
  );

  Publication.fromSnapshot(DocumentSnapshot doc)
      : this.id = doc.data()['id'],
        this.date = doc.data()['date'],
        this.content = List.from(doc.data()['content']),
        this.legend = doc.data()['legend'],
        this.likes = List.from(
          doc.data()['likes'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'date': this.date,
        'content': this.content,
        'legend': this.legend,
        'likes': this.likes,
      };
}

class Content {
  bool isVideo;
  String url;
  String aspectRatio;

  Content(this.isVideo, this.url, this.aspectRatio);

  Map<String, dynamic> toMap() => {
        'isVideo': this.isVideo,
        'url': this.url,
        'aspectRatio': this.aspectRatio,
      };
}

class Comment {
  String id;
  String date;
  String comment;
  String writtenBy;
  List<String> likes = [];
  User writtenByUser;

  Comment({this.comment, this.date, this.writtenBy});

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'comment': this.comment,
        'date': this.date,
        'writtenBy': this.writtenBy,
        'likes': this.likes
      };

  Comment.fromSnapshot(DocumentSnapshot doc)
      : this.id = doc.data()['id'],
        this.date = doc.data()['date'],
        this.comment = doc.data()['comment'],
        this.writtenBy = doc.data()['writtenBy'],
        this.likes = List.from(
          doc.data()['likes'],
        );
}
