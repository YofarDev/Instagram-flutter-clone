import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/database/user_services.dart';
import 'package:instagram_clone/models/publication.dart';


class PublicationServices {
  static CollectionReference users =
  FirebaseFirestore.instance.collection('users');



  static Future<void> addPublication(Publication publication) {
    CollectionReference publications =
    users.doc(UserServices.currentUser).collection('publications');

    return publications
        .add(publication.toMap())
        .then((value) => publications.doc(value.id).update({'id': value.id}));
  }

  static getPublicationsForUser(String id) async {
    List<Publication> publications = [];
    await users.doc(id).collection('publications').get().then((query) {
      query.docs.forEach((value) {
        publications.add(Publication.fromSnapshot(value));
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
      publication = Publication.fromSnapshot(value);
    });

    return publication;
  }

  static updateLike(String userId, String publicationId, bool liked) async {
    CollectionReference publications =
    users.doc(userId).collection('publications');

    if (liked) {
      await publications.doc(publicationId).update({
        'likes': FieldValue.arrayUnion([UserServices.currentUser])
      });
      await users.doc(UserServices.currentUser).update({
        'liked': FieldValue.arrayUnion([publicationId])
      });
    } else {
      await publications.doc(publicationId).update({
        'likes': FieldValue.arrayRemove([UserServices.currentUser])
      });
      await users.doc(UserServices.currentUser).update({
        'liked': FieldValue.arrayRemove([publicationId])
      });
    }
  }


}
