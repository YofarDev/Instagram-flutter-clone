import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String email;
  String pseudo;
  String name;
  String picture;
  String bio;
  List<String> followers = [];
  List<String> following = [];
  List<String> liked = [];
  List<String> mentions = [];

  User(this.email, this.pseudo, this.picture, this.bio);
  User.copyOf(User clone); 

  User.fromSnapshot(DocumentSnapshot doc)
      : this.id = doc.data()['id'],
        this.email = doc.data()['email'],
        this.pseudo = doc.data()['pseudo'],
        this.name = doc.data()['name'],
        this.picture = doc.data()['picture'],
        this.bio = doc.data()['bio'],
        this.followers = List.from(doc.data()['followers']),
        this.following = List.from(doc.data()['following']),
        this.liked = List.from(doc.data()['liked']),
        this.mentions = List.from(doc.data()['mentions']);

  Map<String, dynamic> toMap() => {
        'email': this.email,
        'pseudo': this.pseudo,
        'picture': this.picture,
        'name': this.name,
        'bio': this.bio,
        'followers': this.followers,
        'following': this.following,
        'liked': this.liked,
        'mentions': this.mentions
      };
}

class Mention {
  String mentionBy;
  String publication;

  Mention(this.mentionBy, this.publication);
}
