import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:instagram_clone/models/user.dart';

class UserServices {
  static String currentUserId = fb.FirebaseAuth.instance.currentUser.uid;
  static CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  static Future<void> addUser(User user) =>
      users.doc(user.id).set(user.toMap());

  static Future<void> addFollowing(String idFollowing) {
    // Update the following list of the current user
    users.doc(currentUserId).update({
      'following': FieldValue.arrayUnion([idFollowing])
    }).then((_) => print("New following added in db"));

    // Update the followers list of the new following
    return users.doc(idFollowing).update({
      'followers': FieldValue.arrayUnion([currentUserId])
    }).then((_) => print("New followers added in db"));
  }

  static Future<void> removeFollowing(String idFollowing) {
    // Update the following list of the current user
    users.doc(currentUserId).update({
      'following': FieldValue.arrayRemove([idFollowing])
    }).then((_) => print("New following added in db"));

    // Update the followers list of the new following
    return users.doc(idFollowing).update({
      'followers': FieldValue.arrayRemove([currentUserId])
    }).then((_) => print("New followers added in db"));
  }

  static Future<User> getCurrentUser() async {
    User user;
    await users.doc(currentUserId).get().then((value) {
      user = User.fromMap(value.data());
    });
    return user;
  }

  static Future<User> getUser(String id) async {
    User user;
    await users.doc(id).get().then((value) {
      user = User.fromMap(value.data());
    });
    return user;
  }

  static Future<List<User>> getUsers() async {
    List<User> usersList = [];
    await users.get().then((query) {
      query.docs.forEach((element) {
        usersList.add(User.fromMap(element.data()));
      });
    });

    return usersList;
  }

  static updatePicture(String url) async =>
      users.doc(currentUserId).update({'picture': url});

  static updateUserProfile(User user) async => users.doc(currentUserId).update({
        'name': user.name,
        'username': user.username,
        'bio': user.bio,
      });

  static addConversationToUser(String userId, String conversationId) async {
    users.doc(userId).update({
      'conversationsId': FieldValue.arrayUnion([conversationId])
    });
  }
}
