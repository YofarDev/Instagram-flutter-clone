import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image/image.dart' as img;
import 'package:instagram_clone/services/user_services.dart';
import 'package:uuid/uuid.dart';

class MediaServices {
  static final firebase_storage.Reference usersFolder =
      firebase_storage.FirebaseStorage.instance.ref('/users/');


  static Future<void> uploadProfilePicture(File file, String userId) async {
    img.Image imageBytes = img.decodeImage(file.readAsBytesSync());
    img.Image imageWidthResized = img.copyResize(imageBytes, width: 400);
    img.Image imageResized = img.copyResize(imageWidthResized, height: 400);
    String path = "$userId/profile/img-profile-${Uuid().v1()}.png";

    try {
      // Update file
      await usersFolder.child(path).putData(img.encodePng(imageResized));
      // Get Url
      String url = await usersFolder.child(path).getDownloadURL();
      // Update user on db
      await UserServices.updatePicture(url);

    } on FirebaseException catch (e) {
      print("Error uploading profile picture : $e");
    }
    

  }

  static Future<String> uploadImage(Uint8List image, String userId) async {
    String path = "$userId/published/images/img-${Uuid().v1()}";
    String url = "";
    try {
      await usersFolder.child(path).putData(image);
      url = await usersFolder.child(path).getDownloadURL();

    } on FirebaseException catch (e) {
      print("Error uploading profile picture : $e");
    }
    return url;
  }


}
