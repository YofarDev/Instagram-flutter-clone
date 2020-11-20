import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';


class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  static final firebase_storage.Reference imagesRef =
  firebase_storage.FirebaseStorage.instance.ref('/medias/images/img-profile-719a74e0-2b09-11eb-8a51-5530460cbb75.png');

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
