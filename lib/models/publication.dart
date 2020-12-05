import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/user.dart';

class Publication {
  String id = "";
  String userId;
  String date;
  String legend;
  List<String> content;
  List<String> likes = [];
  int commentCount = 0;
  User user;

  Publication(
      {this.id,
      this.userId,
      this.date,
      this.legend,
      this.content,
      this.likes,
      this.commentCount});

  Publication.newPublication(
      {this.userId, this.date, this.content, this.legend});

  factory Publication.fromMap(Map<String, dynamic> map) => Publication(
        id: map['id'] as String,
        userId: map['userId'] as String,
        date: map['date'] as String,
        legend: map['legend'] as String,
        content: List.from(map['content']),
        likes: List.from(map['likes']),
        commentCount: (map['commentCount']) as int,
      );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'userId': this.userId,
        'date': this.date,
        'legend': this.legend,
        'content': this.content,
        'likes': this.likes,
        'commentCount': this.commentCount,
      };
}

class Content {
  String url;
  bool isVideo;
  double aspectRatio = 1;
  List<User> mentions = [];
  Uint8List bytes;

  Content({
    this.url,
    this.isVideo,
    this.aspectRatio,
    this.mentions,
    this.bytes
  });
}
