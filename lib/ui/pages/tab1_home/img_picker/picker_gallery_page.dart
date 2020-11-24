import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_crop/image_crop.dart';
import 'package:instagram_clone/models/media_file.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/pages/tab1_home/img_picker/custom_crop.dart';
import 'package:instagram_clone/ui/pages/tab1_home/img_picker/filter_selector_page.dart';
import 'package:instagram_clone/ui/common_elements/video_player.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';

class PickerGalleryPage extends StatefulWidget {
  _PickerGalleryPageState createState() => _PickerGalleryPageState();
}

class _PickerGalleryPageState extends State<PickerGalleryPage> {
  final ScrollController _scrollController = ScrollController();
  Future<dynamic> _medias;
  List<MediaFile> _selectedMedias;
  MediaFile _mediaOnView;
  AssetPathEntity _selectedFolder;
  List<MediaFile> _folderFiles;
  bool _multipleMode = false;
  int _selected;
  PhotoViewController _photoViewController;

  @override
  void initState() {
    super.initState();
    _medias = _getMediasList();
    _selectedMedias = [];
    _folderFiles = [];
    _scrollController..addListener(() => _scrollListener());
    _photoViewController = PhotoViewController();
  }

  @override
  void dispose() {
    super.dispose();
    _photoViewController.dispose();
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
        _mediaView(),
        _middleBar(snapshot),
        _gridView(),
      ],
    );
  }

  Widget _appBar() => AppBar(
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
              onPressed: () => _onNextPageTap())
        ],
      );

  Widget _mediaView() => Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.width,
              child: _mediaOnView != null
                  ? (_mediaOnView.isVideo)
                      ? VideoPlayerWidget(_mediaOnView.path, true)
                      : AspectRatio(
                          aspectRatio: 1,
                          child: ClipRect(
                            child: PhotoView(
                              key: ValueKey(_mediaOnView),
                              minScale: PhotoViewComputedScale.covered,
                              maxScale: PhotoViewComputedScale.covered,
                              controller: _photoViewController,
                              backgroundDecoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              imageProvider: FileImage(
                                File(
                                  _mediaOnView.path,
                                ),
                              ),
                            ),
                          ),
                        )
                  : Container()),

          /// Icon multiple mode
          Container(
              padding: EdgeInsets.only(bottom: 20, right: 20),
              height: MediaQuery.of(context).size.width,
              alignment: Alignment.bottomRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: (_multipleMode) ? Colors.blue : AppColors.grey1040,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.dynamic_feed_sharp,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () => _onIconMultipleTap(),
                ),
              ))
        ],
      );

  Widget _middleBar(AsyncSnapshot snapshot) => Row(
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
      );

  Widget _gridView() => _folderFiles.isEmpty
      ? Container()
      : Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 4, mainAxisSpacing: 4),
            controller: _scrollController,
            itemBuilder: (context, i) {
              Uint8List thumb = _folderFiles[i].thumb;
              return GestureDetector(
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      child: Image.memory(
                        thumb,
                        fit: BoxFit.cover,
                      ),
                    ),
                    (i == _selected)
                        ? Container(
                            color: AppColors.white40,
                          )
                        : Container(),
                    (_multipleMode) ? _getBadges(_folderFiles[i]) : Container(),
                  ],
                ),
                onTap: () => _onThumbnailTap(i),
                onLongPress: () => _onThumbnailLongPress(i),
                onDoubleTap: () => _onThumbnailDoubleTap(i),
              );
            },
            itemCount: _folderFiles.length,
          ),
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
              padding: EdgeInsets.only(
                top: 200,
                left: 20,
                right: 20,
              ),
              child: Text(
                AppStrings.emptyGallery,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _getBadges(MediaFile current) {
    bool isSelected = _selectedMedias.contains(current);
    return Positioned(
      right: 0.0,
      width: 36.0,
      height: 36.0,
      child: GestureDetector(
        onTap: () => _onBadgeThumbnailTap(current),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(width: 2, color: Colors.white),
                color: (isSelected) ? Colors.blue : null),
            child: (isSelected)
                ? Text(
                    "${_selectedMedias.indexOf(current) + 1}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  )
                : Container(),
          ),
        ),
      ),
    );
  }

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
      _mediaOnView = _folderFiles[0];
      _selected = 0;
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
        path: file.path,
        thumb: thumb,
        isVideo: isVideo,
        duration: duration,
        width: entity.width,
        height: entity.width,
      ));
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

  Content _convertToContent(File file) {
    return Content(false, file.path, 1);
  }

  Future<File> _getResizedImage(MediaFile media) async {
    var rect = Rect.fromCenter(
        center: media.offset,
        width: media.width.toDouble(),
        height: media.height.toDouble());

    final sampledFile = await ImageCrop.sampleImage(
      file: File(media.path),
      preferredSize: (1200 / media.scale).round(),
    );

    final croppedFile = await ImageCrop.cropImage(
      file: sampledFile,
      area: rect,
    );

    return await ImageCrop.cropImage(
        file: croppedFile, area: rect, scale: media.scale);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) _loadMore();
  }

  // 2 ways of switching multiple mode ON/OFF :
  // - The icon bottom right of the photo view
  // - Long press on a thumbnail
  void _setMultipleMode() {
    setState(() {
      _multipleMode = !_multipleMode;
      // Add the media on photo view when multiple mode is switch ON
      if (_multipleMode)
        _selectedMedias.add(_mediaOnView);
      else
        _selectedMedias = [];
    });
  }

  // To add or remove an item of the selected medias (10 max)
  void _updateMediasSelectedList(MediaFile current) {
    bool isSelected = _selectedMedias.contains(current);
    setState(() {
      if (_selectedMedias.length < 10 && !isSelected) {
        _selectedMedias.add(current);
      }
      if (isSelected) _selectedMedias.remove(current);
      // If we remove the last item of the selection, switch off the multiple mode
      if (_selectedMedias.length == 0) _multipleMode = false;
    });
  }

  void _setThumbnailAsView(int i) {
    _savePosition();
    _photoViewController.reset();
    // If it's a click on the thumbnail we were already,
    // and multiple mode is ON, we add/remove it
    if (_selected == i && _multipleMode)
      _updateMediasSelectedList(_mediaOnView);

    // Else we update the photo view and load saved position if there is one
    setState(() {
      _mediaOnView = _folderFiles[i];
      _selected = i;
      if (_mediaOnView.offset != null)
        _photoViewController.position = _mediaOnView.offset;
    });
  }

  // If the media displaying in photo view is
  // in the list of selected medias, we save its position
  void _savePosition() {
    if (_multipleMode && _selectedMedias.contains(_mediaOnView)) {
      _mediaOnView.offset = _photoViewController.position;
      _mediaOnView.scale = _photoViewController.scale;
    }
  }

  /// MULTIPLE MODE & STUFF LISTENERS

  void _onIconMultipleTap() => _setMultipleMode();

  void _onThumbnailTap(int i) => _setThumbnailAsView(i);

  void _onThumbnailDoubleTap(int i) {
    // If multiple mode is ON, we add/remove the media
    if (_multipleMode) _updateMediasSelectedList(_folderFiles[i]);
    // If it was not already on view, we update it
    if (_folderFiles[i] != _mediaOnView) _setThumbnailAsView(i);
  }

  void _onThumbnailLongPress(int i) {
    _setThumbnailAsView(i);
    _setMultipleMode();
  }

  void _onBadgeThumbnailTap(MediaFile current) =>
      _updateMediasSelectedList(current);

  //ToDo : add videos
  void _onNextPageTap() async {
    List<Content> medias = [];
    _mediaOnView.scale = _photoViewController.scale;
    _mediaOnView.offset = _photoViewController.position;
    if (!_multipleMode) _selectedMedias.add(_mediaOnView);

    for (MediaFile media in _selectedMedias)
      medias.add(_convertToContent(await _getResizedImage(media)));

    // Send the list to the next page
    Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => FilterSelectorPage(
            medias: medias,
          ),
        ));
  }
}
