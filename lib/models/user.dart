class User {
  String id;
  String email;
  String username;
  String name;
  String picture = "";
  String bio = "";
  List<String> followers = [];
  List<String> following = [];
  List<String> liked = [];
  List<String> mentions = [];
  List<String> publicationsId = [];

  User.newUser({this.id, this.email, this.username, this.name});

  User(
      {this.id,
      this.email,
      this.username,
      this.name,
      this.picture,
      this.bio,
      this.followers,
      this.following,
      this.liked,
      this.mentions,
      this.publicationsId});

  factory User.fromMap(Map<String, dynamic> map) {
    return new User(
      id: map['id'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      name: map['name'] as String,
      picture: map['picture'] as String,
      bio: map['bio'] as String,
      followers: List.from(map['followers']),
      following: List.from(map['following']),
      liked:  List.from(map['liked']),
      mentions:  List.from(map['mentions']),
      publicationsId:  List.from(map['publicationsId']),
    );
  }

   Map<String, dynamic> toMap() =>
       { 'id': this.id,
         'email': this.email,
         'username': this.username,
         'name': this.name,
         'picture': this.picture,
         'bio': this.bio,
         'followers': this.followers,
         'following': this.following,
         'liked': this.liked,
         'mentions': this.mentions,
         'publicationsId': this.publicationsId,};


  User.copyOf(User clone);


}

class Mention {
  String mentionBy;
  String publication;

  Mention(this.mentionBy, this.publication);
}
