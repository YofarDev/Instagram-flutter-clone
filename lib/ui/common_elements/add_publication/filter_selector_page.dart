import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:instagram_clone/models/media_file.dart';
import 'package:instagram_clone/res/color_filters.dart';
import 'package:instagram_clone/services/medias_manipulation/image_manipulation.dart';
import 'package:instagram_clone/ui/common_elements/content_slider.dart';
import 'package:instagram_clone/ui/common_elements/add_publication/publication_info_page.dart';

///The PhotoFilterSelector Widget for apply filter from a selected set of filters
class FilterSelectorPage extends StatefulWidget {
  final List<MediaFile> medias;

  const FilterSelectorPage({
    Key key,
    @required this.medias,
  });

  @override
  State<StatefulWidget> createState() => new _FilterSelectorPageState();
}

class _FilterSelectorPageState extends State<FilterSelectorPage> {
  final GlobalKey _globalKey = GlobalKey();
  CarouselController _carouselController;
  final List<List<double>> filters = LIST_MATRIX_DOUBLES;
  final List<String> filtersName = LIST_MATRIX_NAMES;
  List<MediaFile> _medias;
  int _selectedMedia = 0;
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _medias = widget.medias;
    _carouselController = CarouselController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.blue,
              ),
              onPressed: () async {
                _onNextTap();
              },
            )
          ],
        ),
        body: Column(
          children: [
            _repaintWidget(),
            _thumbnails(context),
          ],
        ),
      ),
    );
  }

  Widget _contentSlider() => ContentSlider(
      controller: _carouselController,
      contentBytesList: _medias.map((e) => e.bytes).toList(),
      isBytes: true,
      showDots: false,
      initialPage: _selectedMedia,
      onMediaChanged: (int index) {
        setState(() {
          _selectedMedia = index;
        });
      });

  Widget _repaintWidget() => RepaintBoundary(
        key: _globalKey,
        child: Container(
          child: (_selectedFilter == 0)
              ? _contentSlider()
              : ColorFiltered(
                  child: _contentSlider(),
                  // The filter matrices list doesn't have "normal" filter, so
                  // we need to remove 1 to match the indexes
                  colorFilter: ColorFilter.matrix(filters[_selectedFilter - 1]),
                ),
        ),
      );

  Widget _thumbnails(
    BuildContext context,
  ) =>
      Container(
        height: 200,
        padding: EdgeInsets.all(20),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filtersName.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Text(
                    filtersName[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: (_selectedFilter == index)
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    child: GestureDetector(
                      child: _getFilteredThumbnails(_selectedMedia)[index],
                      onTap: () {
                        setState(() {
                          _selectedFilter = index;
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

  List<Widget> _getFilteredThumbnails(int i) {
    List<Widget> filteredThumbnails = [];
    // For the normal (no filter)
    filteredThumbnails
        .add(Image.memory(_medias[i].bytes, width: 100, height: 100));

    for (var filter in filters)
      filteredThumbnails.add(
        ColorFiltered(
          colorFilter: ColorFilter.matrix(filter),
          child: Image.memory(_medias[i].bytes, width: 100, height: 100),
        ),
      );
    return filteredThumbnails;
  }

  // This is a really bad way of doing things
  // But I'm not really good with image manipulation, matrices, filters etc...
  // I've tried to use Image.colorOffset() and Image.convolution()
  // but I had no idea what I was doing...
  // Pls help
  void _onNextTap() async {
    List<Uint8List> filteredBytes = [];
    filteredBytes.add(await ImageManipulation.getViewAsBytes(
        repaintBoundary: _globalKey.currentContext.findRenderObject()));
    int originalView = _selectedMedia;
    for (int i = 0; i < _medias.length; i++) {
      if (i != originalView) {
        setState(() {
          _selectedMedia = i;
          _carouselController.jumpToPage(_selectedMedia);
        });
        // (it's a very bad design)
        await Future.delayed(Duration(milliseconds: 100)).then(
          (value) async => filteredBytes.add(
            await ImageManipulation.getViewAsBytes(
              repaintBoundary: _globalKey.currentContext.findRenderObject(),
            ),
          ),
        );
      }
    }

    Navigator.of(_globalKey.currentContext).push(MaterialPageRoute(
      builder: (context) => PublicationInfoPage(filteredBytes),
    ));
  }
}
