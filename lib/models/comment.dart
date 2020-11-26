class Comment {
  String id;
  String date;
  String body;
  String writtenById;
  List<String> likes;

  Comment(
      {this.id,
      this.date,
      this.body,
      this.writtenById,
      this.likes});

  factory Comment.fromMap(Map<String, dynamic> map) {
    return new Comment(
      id: map['id'] as String,
      date: map['date'] as String,
      body: map['comment'] as String,
      writtenById: map['writtenById'] as String,
      likes: List.from(map['likes']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'date': this.date,
        'comment': this.body,
        'writtenById': this.writtenById,
        'likes': this.likes,
      };
}
