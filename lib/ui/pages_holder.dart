import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/ui/common_elements/bottom_app_bar.dart';
import 'package:instagram_clone/ui/pages/tab1_home/home_page.dart';
import 'package:instagram_clone/ui/pages/tab2_search/search_page.dart';
import 'package:instagram_clone/ui/pages/tab3_reels/reels_page.dart';
import 'package:instagram_clone/ui/pages/tab4_shop/shop_page.dart';
import 'package:instagram_clone/ui/pages/tab5_user/user_holder.dart';

class PagesHolder extends StatefulWidget {
  final int tab;
  final User user;

  PagesHolder(
    this.tab, {
    this.user,
  });

  _PagesHolderState createState() => _PagesHolderState();
}

class _PagesHolderState extends State<PagesHolder> {
  PageController _pageController;
  List<ScrollController> _scrollControllers = [];
  int _currentPage;
  List<Widget> _screens = [];
  bool _showBottomBar;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollControllers = List.generate(3, (index) => ScrollController());
    _screens = _getScreens();
    _currentPage = widget.tab;
    _showBottomBar = true;

    // To change tab after init
    if (_currentPage != 0)
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _pageController.jumpToPage(_currentPage));
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          controller: _pageController,
          children: _screens,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: (_showBottomBar)
            ? MyBottomAppBar(
                currentPage: _currentPage,
                onPageChange: (int selected) => _onPageChanged(selected),
                onDoubleTap: (int selected, int controller) =>
                    _onDoubleTap(selected, controller),
              )
            : null,
      ),
    );
  }

  _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      // Need to hide bottom bar for current user page (for the animated drawer)
     if (page == 4 && widget.user == null) _showBottomBar = false;
     else _showBottomBar = true;
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
        (widget.user != null)
            ? UserHolder(isCurrent: false, user: widget.user)
            : UserHolder(
                isCurrent: true,
              ),
      ];
}
