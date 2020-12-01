import 'package:instagram_clone/models/conversation.dart';
import 'package:instagram_clone/services/user_services.dart';

extension CapExtension on String {
  String get capitalizeFirstLetter => '${this[0].toUpperCase()}${this.substring(1)}';
  String get capitalize => this.toUpperCase();
  String get capitalizeFirstLetterOfWords => this.split(" ").map((str) => str.capitalizeFirstLetter).join(" ");
}


extension ConversationUtils on Conversation{
  String get getOtherUser => (this.user1 == UserServices.currentUserId) ? 'user2' : 'user1';
  String get getCurrentUser => (this.user1 == UserServices.currentUserId) ? 'user1' : 'user2';
  String get getOtherNotificationsName => (this.user1 == UserServices.currentUserId) ? 'user2Notifications' : 'user1Notifications';
  String get getCurrentNotificationsName => (this.user1 == UserServices.currentUserId) ? 'user1Notifications' : 'user2Notifications';
  int get getOtherNotifications => (this.user1 == UserServices.currentUserId) ? this.user2Notifications : this.user1Notifications;
  int get getCurrentNotifications => (this.user1 == UserServices.currentUserId) ? this.user1Notifications : this.user2Notifications;
}