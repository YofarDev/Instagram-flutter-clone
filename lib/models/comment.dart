class Comment {
  String id;
  String date;
  String body;
  String writtenById;
  String writtenByUsername;
  String writtenByPicture;
  List<String> likes;

  Comment(
      {this.id,
        this.date,
        this.body,
        this.writtenById,
        this.writtenByUsername,
        this.writtenByPicture,
        this.likes});

  factory Comment.fromMap(Map<String, dynamic> map) {
    return new Comment(
      id: map['id'] as String,
      date: map['date'] as String,
      body: map['comment'] as String,
      writtenById: map['writtenById'] as String,
      writtenByUsername: map['writtenByUsername'] as String,
      writtenByPicture: map['writtenByPicture'] as String,
      likes: map['likes'] as List<String>,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': this.id,
    'date': this.date,
    'comment': this.body,
    'writtenById': this.writtenById,
    'writtenByUsername': this.writtenByUsername,
    'writtenByPicture': this.writtenByPicture,
    'likes': this.likes,
  };
}
