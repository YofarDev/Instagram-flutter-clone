import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/conversation.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/services/database/user_services.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/utils/extensions.dart';

class ConversationService {
  static CollectionReference conversations =
      FirebaseFirestore.instance.collection('conversations');
  static CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  static getMessagesSnapshot(String conversationId) => conversations
      .doc(conversationId)
      .collection('messages')
      .orderBy('date', descending: true)
      .snapshots();

  static Future<List<String>> getConversationsListForUser() async => await users
      .doc(UserServices.currentUserId)
      .get()
      .then((value) => User.fromMap(value.data()).conversationsId);

  static Future<Conversation> getConversation(String conversationId) async =>
      await conversations.doc(conversationId).get().then((value) =>
          (value.data() == null) ? null : Conversation.fromMap(value.data()));

  static Future<void> createConversation(Conversation conversation) async =>
      conversations
          .doc(
              Utils.getConversationId([conversation.user1, conversation.user2]))
          .set(conversation.toMap())
          .then((value) {
        UserServices.addConversationToUser(conversation.user1, conversation.id);
        UserServices.addConversationToUser(conversation.user2, conversation.id);
      });

  static Future<void> addMessage(
          String conversationId, Message message) async =>
      conversations
          .doc(conversationId)
          .collection('messages')
          .add(message.toMap())
          .then((value) {

        // Update message id
        conversations
            .doc(conversationId)
            .collection('messages')
            .doc(value.id)
            .update({'id': value.id});

        // Update conversation last message
        conversations.doc(conversationId).update({
          'lastMessageBody': message.body,
          'lastMessageDate': message.date,
        });
      });

  static Future<void> oneMoreNotification(String conversationId) async {
    Conversation conversation = await getConversation(conversationId);
    int notifications = conversation.getOtherNotifications + 1;

    conversations
        .doc(conversationId)
        .update({conversation.getOtherNotificationsName: notifications});
  }

  static Future<Message> getLastMessage(String conversationId) async =>
      await conversations
          .doc(conversationId)
          .collection('messages')
          .orderBy('date')
          .limitToLast(1)
          .get()
          .then((value) => Message.fromMap(value.docs.last.data()));

  static Future<void> resetNotifications(
          String conversationId, String userNotifications) =>
      conversations.doc(conversationId).update({userNotifications: 0});
}
