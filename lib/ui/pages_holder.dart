import 'package:flutter/material.dart';
import 'package:instagram_clone/ui/common_elements/bottom_nav_bar.dart';
import 'package:instagram_clone/ui/pages/tab1_home/home_page.dart';
import 'package:instagram_clone/ui/pages/tab2_search/search_page.dart';
import 'package:instagram_clone/ui/pages/tab3_reels/reels_page.dart';
import 'package:instagram_clone/ui/pages/tab4_shop/shop_page.dart';
import 'package:instagram_clone/ui/pages/tab5_user/user_page.dart';

class PagesHolder extends StatefulWidget {
  final int tab;

  PagesHolder(this.tab);

  _PagesHolderState createState() => _PagesHolderState();
}

class _PagesHolderState extends State<PagesHolder> {
  PageController _pageController;
  List<ScrollController> _scrollControllers = [];
  int _currentPage;
  List<Widget> _screens = [];
  bool _reload;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollControllers = List.generate(3, (index) => ScrollController());
    _screens = _getScreens();
    _currentPage = widget.tab;

    // To change tab after init
    if ( _currentPage != 0)
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _pageController.jumpToPage(_currentPage));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        children: _screens,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavBar(
        currentPage: _currentPage,
        onPageChange: (int selected) => _onPageChanged(selected),
        onDoubleTap: (int selected, int controller) =>
            _onDoubleTap(selected, controller),
      ),
    );
  }

  _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _pageController.jumpToPage(page);
  }

  _onDoubleTap(int page, int index) {
    if (_currentPage != page)
      _onPageChanged(page);
    else if (_scrollControllers[index].hasClients)
      _scrollControllers[index].jumpTo(1);
  }

  _getScreens() => [
        HomePage(_scrollControllers[0]),
        SearchPage(_scrollControllers[1]),
        ReelsPage(),
        ShopPage(),
        UserPage(_scrollControllers[2]),
      ];
}
