import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/services/database/user_services.dart';
import 'package:instagram_clone/models/publication.dart';

class PublicationServices {
  static CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  static Future<void> addPublication(Publication publication) {
    CollectionReference publications =
        users.doc(UserServices.currentUserId).collection('publications');

    return publications
        .add(publication.toMap())
        .then((value) => publications.doc(value.id).update({'id': value.id}));
  }

  static Future<List<Publication>> getPublicationsForUser(String id) async {
    // Get publications of the last 48 hours
    List<Publication> publications = [];
    await users
        .doc(id)
        .collection('publications')
        .get()
        .then((query) {
      query.docs.forEach((value) {
        publications.add(Publication.fromMap(value.data()));
      });
    });

    return publications;
  }

  static Future<List<Publication>> getPublicationsForUserLast48h(String id) async {
    // Get publications of the last 48 hours
    List<Publication> publications = [];
    await users
        .doc(id)
        .collection('publications')
        .where("date",
            isGreaterThan:
                DateTime.now().subtract(Duration(days: 2)).toString())
        .get()
        .then((query) {
      query.docs.forEach((value) {
        publications.add(Publication.fromMap(value.data()));
      });
    });

    return publications;
  }

  static getPublication(String userId, String publicationId) async {
    Publication publication;
    await users
        .doc(userId)
        .collection('publications')
        .doc(publicationId)
        .get()
        .then((value) {
      publication = Publication.fromMap(value.data());
    });

    return publication;
  }

  static updateLike(String userId, String publicationId, bool liked) async {
    CollectionReference publications =
        users.doc(userId).collection('publications');

    if (liked) {
      await publications.doc(publicationId).update({
        'likes': FieldValue.arrayUnion([UserServices.currentUserId])
      });
      await users.doc(UserServices.currentUserId).update({
        'liked': FieldValue.arrayUnion([publicationId])
      });
    } else {
      await publications.doc(publicationId).update({
        'likes': FieldValue.arrayRemove([UserServices.currentUserId])
      });
      await users.doc(UserServices.currentUserId).update({
        'liked': FieldValue.arrayRemove([publicationId])
      });
    }
  }
}
