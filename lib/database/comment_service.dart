import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/database/user_services.dart';
import 'package:instagram_clone/models/publication.dart';

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

    await comments
        .add(comment.toMap())
        .then((value) => comments.doc(value.id).update({'id': value.id}));
  }

  static getCommentsForPublication(String userId, String publicationId) async {
    List<Comment> comments = [];
    await users
        .doc(userId)
        .collection('publications')
        .doc(publicationId)
        .collection('comments')
        .get()
        .then((query) {
      query.docs.forEach((value) {
        comments.add(Comment.fromSnapshot(value));
      });
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
        'likes': FieldValue.arrayUnion([UserServices.currentUser])
      });
    else
      await comments.doc(commentId).update({
        'likes': FieldValue.arrayRemove([UserServices.currentUser])
      });
  }

  static Future<void> deleteComment(
      String userPublicationId, String publicationId, String commentId) async {
    CollectionReference comments = users
        .doc(userPublicationId)
        .collection('publications')
        .doc(publicationId)
        .collection('comments');

    return await comments.doc(commentId).delete();
  }
}