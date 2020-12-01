import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:instagram_clone/services/user_services.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class MediaServices {


  static Future<void> uploadProfilePicture(File file, String userId) async {
    img.Image imageBytes = img.decodeImage(file.readAsBytesSync());
    img.Image imageWidthResized = img.copyResize(imageBytes, width: 400);
    img.Image imageResized = img.copyResize(imageWidthResized, height: 400);
    String path = "$userId/profile/img-profile-${Uuid().v1()}.png";

    try {
      // Upload file
      var request = http.MultipartRequest(
          'POST', Uri.parse("https://yofardev.hd.free.fr/upload.php"));
      request.files.add(http.MultipartFile.fromBytes('image', imageResized.getBytes()));

      var res = await request.send();
      // Get Url
      String url =
      // Update user on db
      await UserServices.updatePicture("url");

    } on Exception catch (e) {
      print("Error uploading profile picture : $e");
    }
    

  }

  static Future<String> uploadImage(Uint8List image, String userId) async {
    String path = "$userId/published/images/img-${Uuid().v1()}";
    String url = "";
    // try {
    //   await usersFolder.child(path).putData(image);
    //   url = await usersFolder.child(path).getDownloadURL();
    //
    // } on FirebaseException catch (e) {
    //   print("Error uploading profile picture : $e");
    // }
    return url;
  }


}
