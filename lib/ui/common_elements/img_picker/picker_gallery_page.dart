import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:instagram_clone/models/media_file.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/common_elements/video_player.dart';
import 'package:instagram_clone/ui/common_elements/img_picker/filter_selector_page.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class PickerGalleryPage extends StatefulWidget {
  _PickerGalleryPageState createState() => _PickerGalleryPageState();
}

class _PickerGalleryPageState extends State<PickerGalleryPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _globalKey = GlobalKey();
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

  /// *********** UI **********

  Widget _getWidgets(AsyncSnapshot snapshot) {
    return Column(
      children: <Widget>[
        _appBar(),
        _mediaView(),
        _foldersPicker(snapshot),
        _thumbnailsGridView(),
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
                      ? VideoPlayerWidget(
                          path: _mediaOnView.path,
                          isFile: true,
                          crop: true,
                        )
                      : AspectRatio(
                          aspectRatio: 1,
                          child: ClipRect(
                            child: RepaintBoundary(
                              key: _globalKey,
                              child: PhotoView(
                                key: ValueKey(_mediaOnView),
                                onTapUp: (context, details, controllerValue) =>
                                    print(_photoViewController.position),
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
                          ),
                        )
                  : Container()),

          // Icon multiple mode
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

  Widget _foldersPicker(AsyncSnapshot snapshot) => Row(
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

  Widget _thumbnailsGridView() => _folderFiles.isEmpty
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
      child: IgnorePointer(
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

  List<DropdownMenuItem> _getDropdownItems(List<AssetPathEntity> list) =>
      list.map((e) {
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

  /// *********** DATA **********

  Future<List<AssetPathEntity>> _getMediasList() async {
    var result = await PhotoManager.requestPermission();
    if (result)
      // Return list of photos/videos by folders
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
      ));
    }
    return files;
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
    if (_multipleMode) {
      _savePosition();
      // If it's a click on the thumbnail we were already,
      // We add or remove it
      if (_selected == i)
        _updateMediasSelectedList(_mediaOnView);
      // If the selected list doesn't contain it and is not full, we add it
      else if (!_selectedMedias.contains(_folderFiles[i]) &&
          (_selectedMedias.length < 10)) _selectedMedias.add(_folderFiles[i]);
    }
    // We could also  _photoViewController.reset(), I don't know which one is better
    _photoViewController = PhotoViewController();
    setState(() {
      // Set the new view
      _mediaOnView = _folderFiles[i];
      _selected = i;
      // To put back the saved position on view [MULTIPLE ON]
      // (don't work without the delay, can't really figure out why)
      if (_multipleMode && _mediaOnView.position != null)
        Future.delayed(Duration(milliseconds: 50)).then(
            (value) => _photoViewController.position = _mediaOnView.position);
    });
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

  // 2 ways of switching multiple mode ON/OFF :
  // - The icon bottom right of the photo view
  // - Long press on a thumbnail
  void _setMultipleMode() {
    setState(() {
      _multipleMode = !_multipleMode;
      // Add the media on photo view when multiple mode is switch ON
      if (_multipleMode) {
        _selectedMedias = [];
        _selectedMedias.add(_mediaOnView);
      } else
        _selectedMedias = [];
    });
  }

  // If the media displaying in media view is
  // in the list of selected medias, we save its position
  Future<void> _savePosition() async {
    _mediaOnView.position = _photoViewController.position;
    var repaintBoundary = _globalKey.currentContext.findRenderObject();
    _mediaOnView.bytes = await _cropView(repaintBoundary);
  }

  Future<Uint8List> _cropView(var repaintBoundary) async {
    ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 1.0);
    ByteData byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }

  /// LISTENERS

  void _onIconMultipleTap() => _setMultipleMode();

  void _onThumbnailTap(int i) => _setThumbnailAsView(i);

  // void _onThumbnailDoubleTap(int i) {
  //   // If multiple mode is ON, we add/remove the media
  //   if (_multipleMode) _updateMediasSelectedList(_folderFiles[i]);
  //   // If it was not already on view, we update it
  //   if (_folderFiles[i] != _mediaOnView) _setThumbnailAsView(i);
  // }

  void _onThumbnailLongPress(int i) {
    _setThumbnailAsView(i);
    _setMultipleMode();
  }

  //void _onBadgeThumbnailTap(MediaFile current) {}

  void _onNextPageTap() async {
    //ToDo : add videos
    if (!_multipleMode) {
      _selectedMedias = [];
      var repaintBoundary = _globalKey.currentContext.findRenderObject();
      _mediaOnView.bytes = await _cropView(repaintBoundary);
      _selectedMedias.add(_mediaOnView);
    }
    // // Send the list to the next page
    Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => FilterSelectorPage(
            medias: _selectedMedias,
          ),
        ));
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) _loadMore();
  }
}
