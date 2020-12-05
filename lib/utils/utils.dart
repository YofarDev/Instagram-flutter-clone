import 'package:flutter/material.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/services/database/user_services.dart';
import 'package:instagram_clone/ui/pages/tab5_user/user_holder.dart';
import 'package:instagram_clone/ui/pages_holder.dart';
import 'package:timeago/timeago.dart' as timeago;

class Utils {
  ///*** OBJECTS TO STRING ***///
  /// CONTENT ///
  static String itemContentToStr(Content content) =>
      "${content.isVideo}||${content.url}||${content.aspectRatio}";

  static Content strToItemContent(String c) {
    List<String> list = c.replaceAll(' ', '').split('||');
    bool b = list[0] == 'true' ? true : false;
    return (Content(
      isVideo: b,
      url: list[1],
      aspectRatio: double.parse(
        list[2],
      ),
    ));
  }

  /// MENTION ////
  static String mentionToStr(Mention mention) =>
      "${mention.mentionBy}||${mention.publication}";

  static Mention strToMention(String str) {
    List<String> list = str.replaceAll(' ', '').split('||');
    return Mention(list[0], list[1]);
  }

  ///*** OTHERS ***///

  // ToDo : manage locale
  static String getHowLongAgo(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return timeago.format(date, locale: 'en_short');
  }

  static String getHowLongAgoLonger(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return timeago.format(date);
  }

  static getProfilePic(String url) => (url.isNotEmpty)
      ? NetworkImage(url)
      : AssetImage("assets/images/default-profile.png");

  static navToUserDetails(BuildContext context, User user) =>
     Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => (user.id != UserServices.currentUserId)
            ? PagesHolder(4, user: user)
            : UserHolder(
                isCurrent: true,
                user: user,
              ),
      ));

  static String getConversationId(List<String> ids) {
    ids.sort();
    String conversationId = "";
    for (int i = 0; i < ids[0].length; i++) {
      var char1 = ids[0][i];
      var char2 = ids[1][i];
      conversationId += char1 + char2;
    }
    return conversationId;
  }

  static List<String> getUserIdsFromConversationId(String conversationId) {
    String id1 = "";
    String id2 = "";
    for (int i = 0; i < conversationId.length; i += 2) {
      id1 += conversationId[i];
      id2 += conversationId[i + 1];
    }
    return [id1, id2];
  }
}
