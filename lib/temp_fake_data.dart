import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/database/user_services.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/utils/utils.dart';

class FakeData {
  static String currentUser = "WRAjlm4sMFdMWa7Tdn5z";
  static String user1 = "TFBw5WQa4urXxKNXHguh";
  static String user2 = "keEObNdK2zrDpPC6b7wC";
  static CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  static List<User> getUsers = [
    User(
      "mail",
      "zemmourofficial",
      "assets/images/igp1.jpg",
      "Fuck le grand remplacement",
    ),
    User(
      "mail",
      "polanski.nautik",
      "assets/images/igp2.jpeg",
      "Popular realisator until I raped a kid",
    ),
    User("me", "yofaraway", "assets/images/igp3.jpg",
        "Traveling around \bProfesionnal photographer (absolument pas)"),
  ];

  static List<Publication> getPublications = [
    Publication(
        DateTime.now().toString(),
        [Utils.contentToStr(Content(false, "assets/images/ig1.jpg", "1.91"))],
        "Like si ils sont cute"),
    Publication(
        "2020-11-08 13:04:11.835",
        [Utils.contentToStr(Content(false, "assets/images/ig3.jpg", "1.91"))],
        "Peace."),
    Publication(
        "2020-11-08 12:04:11.835",
        [Utils.contentToStr(Content(false, "assets/images/ig2.jpg", "1"))],
        "Délicieux"),
    Publication(
        "2020-10-08 12:04:11.835",
        [
          Utils.contentToStr(Content(false, "assets/images/ig4.jpg", "1.91")),
          Utils.contentToStr(Content(false, "assets/images/ig5.jpg", "1.91"))
        ],
        "Paris"),
    Publication(
        "2020-10-14 12:04:11.835",
        [
          Utils.contentToStr(Content(false, "assets/images/ig6.png", "0.8")),
          Utils.contentToStr(Content(false, "assets/images/ig7.png", "0.8"))
        ],
        "C'est moi que de bons souvenirs en cette belle après-midi à Aix"),
  ];

  static populateDb() async {
    await addPublicationForUser(getPublications[0], user1);
    await addPublicationForUser(getPublications[1], user1);
    await addPublicationForUser(getPublications[2], user2);
    await addPublicationForUser(getPublications[3], user2);
    await addPublicationForUser(getPublications[4], currentUser);
  }

  static Future<void> addPublicationForUser(
      Publication publication, String id) async {
    await users
        .doc(id)
        .collection('publications')
        .add(publication.toMap())
        .then((value) => users
            .doc(id)
            .collection('publications')
            .doc(value.id)
            .update({'id': value.id}));
  }
}
