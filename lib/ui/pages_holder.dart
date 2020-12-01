import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final bool darkTheme;

  PagesHolder(
    this.tab, {
    this.user,
    this.darkTheme,
  });

  _PagesHolderState createState() => _PagesHolderState();
}

class _PagesHolderState extends State<PagesHolder> {
  PageController _pageController;
  List<ScrollController> _scrollControllers = [];
  int _currentPage;
  List<Widget> _screens = [];
  bool _showBottomBar;
  bool _darkThemeBottomBar;
  bool _reload = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollControllers = List.generate(3, (index) => ScrollController());
    _screens = _getScreens();
    _currentPage = widget.tab;
    _darkThemeBottomBar = widget.darkTheme ?? false;
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
                darkTheme: _darkThemeBottomBar,
                currentPage: _currentPage,
                onPageChange: (int selected) => _onPageChanged(selected),
              )
            : null,
      ),
    );
  }

  _onPageChanged(int page) {
    _setSpecificSettings(page);
    setState(() {
      _reload = _currentPage == page;
      _currentPage = page;
      // Need to hide bottom bar for current user page (for the animated drawer)
      if (page == 4 && widget.user == null || _reload)
        _showBottomBar = false;
      else
        _showBottomBar = true;
      _screens = _getScreens();

    });
    _pageController.jumpToPage(page);


  }

  void _setSpecificSettings(int page) {
    if (page != 2) {
      setState(() {
        _darkThemeBottomBar = false;
      });

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark));
    }
    // For ReelsPage
    else {
      setState(() {
        _darkThemeBottomBar = true;
      });

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light));
    }
  }



  _getScreens() => [
        HomePage(_scrollControllers[0]),
        SearchPage(_scrollControllers[1]),
        ReelsPage(),
        ShopPage(),
    // If we have a user as a parameter, we want the UserDetailsPage
        (widget.user != null && !_reload)
            ? UserHolder(isCurrent: false, user: widget.user)
            : UserHolder(
                isCurrent: true,
              ),
      ];
}
