import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:instagram_clone/res/color_filters.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;


///The PhotoFilterSelector Widget for apply filter from a selected set of filters
class FilterSelectorPage extends StatefulWidget {
  final File file;

  const FilterSelectorPage({
    Key key,
    @required this.file,
  });

  @override
  State<StatefulWidget> createState() => new _FilterSelectorPageState();
}

class _FilterSelectorPageState extends State<FilterSelectorPage> {
  final GlobalKey _globalKey = GlobalKey();
  final List<List<double>> filters = LIST_MATRIX_DOUBLES;
  final List<String> filtersName = LIST_MATRIX_NAMES;
  File file;
  int selected = 0;

  @override
  void initState() {
    super.initState();
    file = widget.file;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
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
                convertWidgetToImage();
              },
            )
          ],
        ),
        body: Column(
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                height: MediaQuery.of(context).size.width,
                child: (selected == 0)
                    ? Image.file(
                        File(
                          file.path,
                        ),
                        fit: BoxFit.cover,
                      )
                    : ColorFiltered(
                        child: Image.file(
                          File(
                            file.path,
                          ),
                        ),
                        colorFilter: ColorFilter.matrix(filters[selected - 1]),
                      ),
              ),
            ),
            getThumbnails(context)
          ],
        ),
      ),
    );
  }

  getThumbnails(
    BuildContext context,
  ) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Text(filtersName[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: (selected == index) ? Colors.black : Colors.grey,
                    )),
                Container(
                  padding: EdgeInsets.only(top: 5),
                  child: GestureDetector(
                    child: getFilteredImages()[index],
                    onTap: () {
                      setState(() {
                        selected = index;
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
  }

  getFilteredImages() {
    List<Widget> list = [];
    list.add(Image.file(File(file.path), width: 100, height: 100));

    for (var filter in filters)
      list.add(
        ColorFiltered(
          colorFilter: ColorFilter.matrix(filter),
          child: Image.file(File(file.path), width: 100, height: 100),
        ),
      );

    return list;
  }

  void convertWidgetToImage() async {
    RenderRepaintBoundary repaintBoundary =
        _globalKey.currentContext.findRenderObject();
    ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 1);
    ByteData byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8list = byteData.buffer.asUint8List();
    Navigator.of(_globalKey.currentContext).push(MaterialPageRoute(
        builder: (context) => null));
  }
}
