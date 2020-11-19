import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/strings.dart';

class Utils {
  ///*** OBJECTS TO STRING ***///
  /// CONTENT ///
  static String contentToStr(Content content) =>
      "${content.isVideo}||${content.url}||${content.aspectRatio}";

  static Content strToContent(String c) {
    List<String> list = c.replaceAll(' ', '').split('||');
    bool b = list[0] == 'true' ? true : false;
    return (Content(b, list[1], list[2]));
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

  static String getHowLongAgo(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    int diff = DateTime.now().difference(date).inMinutes;
    String howLongAgo;

    /***
     *
     * For reference, in minutes :
     * 1 day = 1 440
     * 1 week = 10 080
     * 1 month (30 days) = 43 200
     * 1 year = 525 600
     *
     * ***/

    if (diff <= 1)
      howLongAgo = "1${AppStrings.minute}";
    else if (diff > 1 && diff < 60)
      howLongAgo = "$diff${AppStrings.minute}";
    else if (diff >= 60 && diff < 1440)
      howLongAgo =
          "${DateTime.now().difference(date).inHours}${AppStrings.hour}";
    else if (diff >= 1440 && diff < 10080)
      howLongAgo =
          "${(DateTime.now().difference(date).inDays).floor()}${AppStrings.day}";
    else if (diff >= 10080 && diff < 43200)
      howLongAgo =
          "${(DateTime.now().difference(date).inDays / 7).floor()}${AppStrings.week}";
    else if (diff >= 43200 && diff < 525600)
      howLongAgo =
          "${(DateTime.now().difference(date).inDays / 30).floor()}${AppStrings.month}";
    else
      howLongAgo =
          "${(DateTime.now().difference(date).inDays / 365).floor()}${AppStrings.year}";

    return howLongAgo;
  }
}
