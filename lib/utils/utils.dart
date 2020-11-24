import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:flutter/material.dart';
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
      b,
      list[1],
      double.parse(
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
  static String uppercaseFirstLetter(String str) =>
      "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}";

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
}
