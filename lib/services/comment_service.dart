import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/services/user_services.dart';

class CommentServices {
  static CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  static addComment(
      String userPublicationId, String publicationId, Comment comment) async {
    CollectionReference comments = users
        .doc(userPublicationId)
        .collection('publications')
        .doc(publicationId)
        .collection('comments');

    comments.get().then((value) => print(value.docs.length));

    await comments
        .add(comment.toMap())
        .then((value) => comments.doc(value.id).update({'id': value.id}));

    comments.get().then((value) => users
        .doc(userPublicationId)
        .collection('publications')
        .doc(publicationId)
        .update({"commentCount": value.docs.length}));
  }

  static getCommentsForPublication(String userId, String publicationId) async {
    List<Comment> comments = [];
    await users
        .doc(userId)
        .collection('publications')
        .doc(publicationId)
        .collection('comments')
        .orderBy('date', descending: false)
        .limit(3)
        .get()
        .then((query) {
      query.docs.forEach((value) {});
    });
    return comments;
  }

  static likeComment(String userPublicationId, String publicationId,
      String commentId, bool liked) async {
    CollectionReference comments = users
        .doc(userPublicationId)
        .collection('publications')
        .doc(publicationId)
        .collection('comments');

    if (liked)
      await comments.doc(commentId).update({
        'likes': FieldValue.arrayUnion([UserServices.currentUserId])
      });
    else
      await comments.doc(commentId).update({
        'likes': FieldValue.arrayRemove([UserServices.currentUserId])
      });
  }

  static Future<void> deleteComment(
      String userPublicationId, String publicationId, String commentId) async {
    CollectionReference comments = users
        .doc(userPublicationId)
        .collection('publications')
        .doc(publicationId)
        .collection('comments');

    comments.get().then((value) => users
        .doc(userPublicationId)
        .collection('publications')
        .doc(publicationId)
        .update({"commentCount": value.docs.length}));

    return await comments.doc(commentId).delete();
  }

  static getSnapshotCommentsForPublication(
          String userId, String publicationId) =>
      users
          .doc(userId)
          .collection('publications')
          .doc(publicationId)
          .collection('comments')
          .orderBy('date')
          .snapshots();
}
