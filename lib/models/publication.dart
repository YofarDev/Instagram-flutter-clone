import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/user.dart';

class Publication {
  String id = "";
  String userId;
  String date;
  String legend;
  List<String> content;
  List<String> likes = [];
  List<String> commentsId = [];
  User user;

  Publication(
      {this.id,
      this.userId,
      this.date,
      this.legend,
      this.content,
      this.likes,
      this.commentsId});

  Publication.newPublication(
      {this.userId, this.date, this.content, this.legend});

  factory Publication.fromMap(Map<String, dynamic> map) => Publication(
        id: map['id'] as String,
        userId: map['userId'] as String,
        date: map['date'] as String,
        legend: map['legend'] as String,
        content: List.from(map['content']),
        likes: List.from(map['likes']),
        commentsId: List.from(map['commentsId']),
      );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'userId': this.userId,
        'date': this.date,
        'legend': this.legend,
        'content': this.content,
        'likes': this.likes,
        'commentsId': this.commentsId,
      };
}

class Content {
  bool isVideo;
  String url;
  double aspectRatio;

  Content(this.isVideo, this.url, this.aspectRatio);

  Map<String, dynamic> toMap() => {
        'isVideo': this.isVideo,
        'url': this.url,
        'aspectRatio': this.aspectRatio,
      };
}
