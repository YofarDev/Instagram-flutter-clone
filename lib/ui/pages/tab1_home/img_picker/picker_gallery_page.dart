import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:instagram_clone/models/media_file.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/pages/tab1_home/img_picker/filter_selector_page.dart';
import 'package:instagram_clone/ui/common_elements/video_player.dart';
import 'package:photo_manager/photo_manager.dart';

class PickerGalleryPage extends StatefulWidget {
  _PickerGalleryPageState createState() => _PickerGalleryPageState();
}

class _PickerGalleryPageState extends State<PickerGalleryPage> {
  final _cropKey = GlobalKey<CropState>();
  final ScrollController _scrollController = ScrollController();
  Future<dynamic> _medias;
  MediaFile _media;
  AssetPathEntity _selectedFolder;
  List<MediaFile> _folderFiles;

  @override
  void initState() {
    super.initState();
    _medias = _getMediasList();
    _folderFiles = [];
    _scrollController..addListener(() => _scrollListener());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _medias,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty)
                return _emptyGallery();
              else
                return _getWidgets(snapshot);
            } else
              return LoadingWidget();
          },
        ),
      ),
    );
  }

  Widget _getWidgets(AsyncSnapshot snapshot) {
    return Column(
      children: <Widget>[
        _appBar(),

        /// THUMBNAIL
        Container(
            height: MediaQuery.of(context).size.width,
            child: _media != null
                ? (_media.isVideo)
                    ? VideoPlayerWidget(_media.path, true)
                    : Crop(
                        maximumScale: 2,
                        key: _cropKey,
                        image: FileImage(File(_media.path)),
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
                    items: _getDropdownItems(snapshot.data),
                    onChanged: (assetPathEntity) {
                      _setSelectedFolder(assetPathEntity);
                      setState(() {
                        _selectedFolder = assetPathEntity;
                      });
                    },
                    value: _selectedFolder,
                  ),
                )),
          ],
        ),

        /// LIST GALLERY
        _folderFiles.isEmpty
            ? Container()
            : Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4),
                  controller: _scrollController,
                  itemBuilder: (context, i) {
                    Uint8List thumb = _folderFiles[i].thumb;
                    return GestureDetector(
                      child: Image.memory(
                        thumb,
                        fit: BoxFit.cover,
                      ),
                      onTap: () {
                        setState(() {
                          _media = _folderFiles[i];
                        });
                      },
                    );
                  },
                  itemCount: _folderFiles.length,
                ),
              )
      ],
    );
  }

  Widget _appBar()=>AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    title: Text(
      AppStrings.newPost,
      style: TextStyle(color: Colors.black),
    ),
    leading: IconButton(
      icon: Icon(
        Icons.clear,
      ),
      onPressed: () => Navigator.of(context).pop(),
    ),
    actions: [
      IconButton(
          icon: Icon(
            Icons.arrow_forward,
            color: Colors.blue,
          ),
          onPressed: ()=> _onNextTap())
    ],
  );

  Widget _emptyGallery() => Column(
        children: [
          AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back),
              color: Colors.black,
            ),
          ),
          Align(
            child: Padding(
              padding: EdgeInsets.only(top: 200, left:20, right:20,),
              child: Text(
                AppStrings.emptyGallery,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      );

  Future<List<AssetPathEntity>> _getMediasList() async {
    var result = await PhotoManager.requestPermission();
    if (result)
      return await PhotoManager.getAssetPathList().then((value) {
        if (value.isNotEmpty) {
          _selectedFolder = value[0];
          _setSelectedFolder(value[0]);
          return value;
        } else
          return [];
      });
    else
      return null;
  }

  List<DropdownMenuItem> _getDropdownItems(List<AssetPathEntity> list) {
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

  void _setSelectedFolder(AssetPathEntity folder) async {
    List<MediaFile> files = await _loadData(folder, 0);
    setState(() {
      _folderFiles = files;
      _media = _folderFiles[0];
    });
  }

  Future<List<MediaFile>> _loadData(AssetPathEntity folder, int range) async {
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

  void _loadMore() async {
    int range = _folderFiles.length;
    List<MediaFile> files = await _loadData(_selectedFolder, range);
    setState(() {
      _folderFiles.addAll(files);
    });
  }

  void _onNextTap() async {
    if (_media.isVideo) {
    } else {
      File file = await _getCroppedImage();
      Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => FilterSelectorPage(
              file: file,
            ),
          ));
    }
  }

  Future<File> _getCroppedImage() async {
    final crop = _cropKey.currentState;
    final sampledFile = await ImageCrop.sampleImage(
      file: File(_media.path),
      preferredSize: (1200 / crop.scale).round(),
    );

    final croppedFile = await ImageCrop.cropImage(
      file: sampledFile,
      area: crop.area,
    );

    return croppedFile;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) _loadMore();
  }
}
