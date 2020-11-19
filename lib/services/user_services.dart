import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:instagram_clone/models/user.dart';

class UserServices {
  static String currentUser = fb.FirebaseAuth.instance.currentUser.uid;
  static CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  static Future<void> addUser(User user) {
    return users
        .add(user.toMap())
        .then((value) => users.doc(value.id).update({'id': value.id}));
  }

  static Future<void> addFollowing(String idFollowing) {
    // Update the following list of the current user
    users.doc(currentUser).update({
      'following': FieldValue.arrayUnion([idFollowing])
    }).then((_) => print("New following added in db"));

    // Update the followers list of the new following
    return users.doc(idFollowing).update({
      'followers': FieldValue.arrayUnion([currentUser])
    }).then((_) => print("New followers added in db"));
  }

  static getCurrentUser() async {
    User user;
    await users.doc(currentUser).get().then((value) {
      user = User.fromSnapshot(value);
    });
    return user;
  }

  static getUser(String id) async {
    User user;
    await users.doc(id).get().then((value) {
      user = User.fromSnapshot(value);
    });
    return user;
  }
}
