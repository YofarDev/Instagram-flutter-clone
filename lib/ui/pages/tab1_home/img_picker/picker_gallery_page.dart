import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:instagram_clone/models/media_file.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/pages/tab1_home/img_picker/filter_selector_page.dart';
import 'package:instagram_clone/ui/pages/tab1_home/img_picker/picker_app_bar.dart';
import 'package:instagram_clone/ui/common_elements/video_player.dart';
import 'package:photo_manager/photo_manager.dart';

class PickerGalleryPage extends StatefulWidget {
  _PickerGalleryPageState createState() => _PickerGalleryPageState();
}

class _PickerGalleryPageState extends State<PickerGalleryPage> {
  final cropKey = GlobalKey<CropState>();
  final ScrollController controller = ScrollController();
  Future<dynamic> medias;
  MediaFile media;
  AssetPathEntity selectedFolder;
  List<MediaFile> folderFiles;

  @override
  void initState() {
    super.initState();
    medias = getMediasList();
    folderFiles = [];
    controller..addListener(() => scrollListener());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: medias,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return _widgets(snapshot);
            } else
              return LoadingWidget();
          },
        ),
      ),
    );
  }

  _widgets(AsyncSnapshot snapshot) {
    return Column(
      children: <Widget>[
        PickerAppBar(() => onNextTap()),

        /// THUMBMAIL
        Container(
            height: MediaQuery.of(context).size.width,
            child: media != null
                ? (media.isVideo)
                    ? VideoPlayerWidget(media.path, true)
                    : Crop(
                        maximumScale: 2,
                        key: cropKey,
                        image: FileImage(File(media.path)),
                        aspectRatio: 1,
                      )
                : Container()),

        /// MIDDLE BAR
        Row(
          children: [
            Container(
                padding: EdgeInsets.only(left: 15),
                height: 50,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    items: getDropdownItems(snapshot.data),
                    onChanged: (assetPathEntity) {
                      setSelectedFolder(assetPathEntity);
                      setState(() {
                        selectedFolder = assetPathEntity;
                      });
                    },
                    value: selectedFolder,
                  ),
                )),
          ],
        ),

        /// LIST GALLERY
        folderFiles.isEmpty
            ? Container()
            : Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4),
                  controller: controller,
                  itemBuilder: (context, i) {
                    Uint8List thumb = folderFiles[i].thumb;
                    return GestureDetector(
                      child: Image.memory(
                        thumb,
                        fit: BoxFit.cover,
                      ),
                      onTap: () {
                        setState(() {
                          media = folderFiles[i];
                        });
                      },
                    );
                  },
                  itemCount: folderFiles.length,
                ),
              )
      ],
    );
  }

  Future<List<AssetPathEntity>> getMediasList() async {
    var result = await PhotoManager.requestPermission();
    if (result)
      return await PhotoManager.getAssetPathList().then((value) {
        selectedFolder = value[0];
        setSelectedFolder(value[0]);
        return value;
      });
    else
      return null;
  }

  getDropdownItems(List<AssetPathEntity> list) {
    return list.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(
              e.name,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList() ??
        [];
  }

  getFolderChildren(AssetPathEntity folder) async => await folder.assetList;

  getFile(AssetEntity entity) async => await entity.file;

  setSelectedFolder(AssetPathEntity folder) async {
    List<MediaFile> files = await loadData(folder, 0);
    setState(() {
      folderFiles = files;
      media = folderFiles[0];
    });
  }

  loadData(AssetPathEntity folder, int range) async {
    List<AssetEntity> children =
        await folder.getAssetListRange(start: range, end: range + 36);
    List<MediaFile> files = [];

    children.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

    for (AssetEntity entity in children) {
      File file = await entity.file;
      Uint8List thumb = await entity.thumbDataWithSize(150, 150);
      bool isVideo = (entity.typeInt == 2);
      int duration;
      if (isVideo) duration = entity.duration;
      files.add(MediaFile(
          path: file.path, thumb: thumb, isVideo: isVideo, duration: duration));
    }
    return files;
  }

  loadMore() async {
    int range = folderFiles.length;
    List<MediaFile> files = await loadData(selectedFolder, range);
    setState(() {
      folderFiles.addAll(files);
    });
  }

  onNextTap() async {
    if (media.isVideo) {
      
    } else {
      File file = await getCroppedImage();
      Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => FilterSelectorPage(
              file: file,
            ),
          ));
    }
  }

  getCroppedImage() async {
    final crop = cropKey.currentState;
    final sampledFile = await ImageCrop.sampleImage(
      file: File(media.path),
      preferredSize: (1200 / crop.scale).round(),
    );

    final croppedFile = await ImageCrop.cropImage(
      file: sampledFile,
      area: crop.area,
    );

    return croppedFile;
  }

  scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent)
      loadMore();
  }
}
