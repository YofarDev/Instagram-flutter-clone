import 'dart:io';
import 'dart:typed_data';

import 'package:instagram_clone/models/media_file.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaFilesFolders{

  /// Return list of photos/videos by folders
  static Future<List<AssetPathEntity>> getMediasList() async {
    var result = await PhotoManager.requestPermission();
    if (result)

      return await PhotoManager.getAssetPathList();
    else return null;
  }

  /// Return photos/videos in a folder as MediaFile objects
  static Future<List<MediaFile>> loadMediasFromFolder(AssetPathEntity folder, int range) async {
    // Medias in folder
    List<AssetEntity> children =
    await folder.getAssetListRange(start: range, end: range + 36);
    List<MediaFile> mediaFiles = [];
    // Sort by recent to old
    children.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

    for (AssetEntity entity in children) {
      File file = await entity.file;
      // Thumbnail
      Uint8List thumb = await entity.thumbDataWithSize(150, 150);
      // Video information
      bool isVideo = (entity.typeInt == 2);
      int duration;
      if (isVideo) duration = entity.duration;

      // Into a MediaFile object
      mediaFiles.add(MediaFile(
        path: file.path,
        thumb: thumb,
        isVideo: isVideo,
        duration: duration,
      ));
    }
    return mediaFiles;
  }

}