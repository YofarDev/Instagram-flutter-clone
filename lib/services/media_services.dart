import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MediaServices{

  firebase_storage.Reference imagesRef =
  firebase_storage.FirebaseStorage.instance.ref('/medias/images/');

  static Future<void>uploadFile(File file) async{
  }

}