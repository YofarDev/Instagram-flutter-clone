import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/pages/tab2_search/search_open_page.dart';
import 'package:instagram_clone/ui/common_elements/persistent_header.dart';

class SearchPage extends StatefulWidget {
  final ScrollController scrollController;
  SearchPage(this.scrollController);

  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController;
  static const int _itemCount = 21;
  List<StaggeredTile> _tiles;

  @override
  void initState() {
    super.initState();
    _scrollController =widget.scrollController;
    _scrollController..addListener(() => _scrollListener());
    _tiles = _generateRandomTiles(_itemCount).toList();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
        child: CustomScrollView(
      primary: false,
      controller: _scrollController,
      slivers: [
        _searchBar(),
        _categoriesBoxes(),
        _staggeredGridView(),
        SliverToBoxAdapter(
          child: LoadingWidget(),
        ),
      ],
    ));
  }

  Widget _searchBar() => SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchOpenPage(),
            )),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppStrings.search,
                    filled: true,
                    hintStyle: TextStyle(color: AppColors.grey50),
                    fillColor: AppColors.grey1010),
              ),
            ),
          ),
        ),
      );

  Widget _staggeredGridView() => SliverStaggeredGrid.countBuilder(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        staggeredTileBuilder: _getTile,
        itemBuilder: _getChild,
        itemCount: _tiles.length,
      );

  Widget _getChild(BuildContext context, int index) {
    return Container(
      key: ObjectKey('$index'),
      color: _getRandomColor(),
      child: Center(
        child: Text(
          _getRandomContent(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _categoriesBoxes() {
    List<String> categories = AppStrings.CATEGORIES;
    return SliverPersistentHeader(
      pinned: true,
      delegate: PersistentHeader(
        widget: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _getBox(categories[index], index);
          },
        ),
      ),
    );
  }

  Widget _getBox(String title, int index) => Padding(
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          child: OutlineButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: () => print(index),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );

  StaggeredTile _getTile(int index) => _tiles[index];

  List<StaggeredTile> _generateRandomTiles(int count) {
    Random rnd = Random();
    List<StaggeredTile> list = [];
    for (int i = 0; i < count; i++) {
      int proba = rnd.nextInt(10);
       if (proba == 1)
        list.add(StaggeredTile.count(2, 2));
      else
        list.add(StaggeredTile.count(1, 1));
    }
    return list;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) _loadMore();
  }

  void _loadMore() {
    setState(() {
      _tiles.addAll(_generateRandomTiles(_itemCount));
    });
  }

  Color _getRandomColor() {
    // Define all colors you want here
    const predefinedColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.cyan,
      Colors.greenAccent,
      Colors.purpleAccent,
    ];
    Random random = Random();
    return predefinedColors[random.nextInt(predefinedColors.length)];
  }

  String _getRandomContent() {
    // Define all colors you want here
    const predefinedContent = [
      "Tiktok of a sexy girl dancing",
      "Tiktok of a sexy girl dancing",
      "Tiktok of a sexy girl dancing",
      "Video of a cute cat",
      "Selfie of a reality TV random couple",
      "Meme from 2 years ago",
      "Meme from 2 years ago",
      "Influencer funny video",
      "BOOBS",
      "BIG BOOBS",
      "Average boobs but still nice",
      "Fit guy, really nice body",
      "Funny video",
      "Cooking recipe",
      "DIY stuff, impressive but useless"
          "Meaningful quote",
      "Ads",
      "Sponsored publication",
      "Twitter's screen from 6 months ago",
    ];
    Random random = Random();
    return predefinedContent[random.nextInt(predefinedContent.length)];
  }
}
