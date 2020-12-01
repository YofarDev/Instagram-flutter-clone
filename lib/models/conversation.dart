class Conversation {
  String id;
  String user1;
  String user2;
  String lastMessageDate;
  String lastMessageBody;
  int user1Notifications;
  int user2Notifications;

  Conversation(
      {this.id,
      this.user1,
      this.user2,
      this.lastMessageDate,
      this.lastMessageBody,
      this.user1Notifications
        ,
        this.user2Notifications});

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return new Conversation(
      id: map['id'] as String,
      user1: map['user1'] as String,
      user2: map['user2'] as String,
      lastMessageDate: map['lastMessageDate'] as String,
      lastMessageBody: map['lastMessageBody'] as String,
      user1Notifications: map['user1Notifications'] as int,
      user2Notifications: map['user2Notifications'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'user1': this.user1,
        'user2': this.user2,
        'lastMessageDate': this.lastMessageDate,
        'lastMessageBody': this.lastMessageBody,
        'user1Notifications': this.user1Notifications,
    'user2Notifications': this.user2Notifications,
      };
}

class Message {
  String id;
  String userId;
  String body;
  String date;
  bool firstOfGroup;

  Message({
    this.id,
    this.userId,
    this.body,
    this.date,
    this.firstOfGroup,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return new Message(
      id: map['id'] as String,
      userId: map['userId'] as String,
      body: map['body'] as String,
      date: map['date'] as String,
      firstOfGroup: map['firstOfGroup'] as bool,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'userId': this.userId,
        'body': this.body,
        'date': this.date,
        'firstOfGroup': this.firstOfGroup,
      };
}
