import 'package:flutter/material.dart';
import 'package:instagram_clone/ui/common_elements/ig_bottom_bar.dart';
import 'package:instagram_clone/ui/pages/tab1_home/home_page.dart';
import 'package:instagram_clone/ui/pages/tab2_search/search_page.dart';
import 'package:instagram_clone/ui/pages/tab3_reels/reels_page.dart';
import 'package:instagram_clone/ui/pages/tab4_shop/shop_page.dart';
import 'package:instagram_clone/ui/pages/tab5_user/user_page.dart';

class PagesHolder extends StatefulWidget {
  _PagesHolderState createState() => _PagesHolderState();
}

class _PagesHolderState extends State<PagesHolder> {
  PageController _pageController = PageController();
  List<ScrollController> controllers = [];
  int currentPage;
  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    currentPage = 0;
    controllers = [
      ScrollController(),
      ScrollController(),
    ];

    _screens = [
      HomePage(controllers[0]),
      SearchPage(),
      ReelsPage(),
     ShopPage(),
      UserPage(controllers[1]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: IgBottomBar(
        currentPage: currentPage,
        onPageChange: (int selected) => onPageChanged(selected),
        onDoubleTap: (int selected, int controller) =>
            onDoubleTap(selected, controller),
      ),
    );
  }

  onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _pageController.jumpToPage(page);
  }

  onDoubleTap(int page, int index) {
    if (currentPage != page)
      onPageChanged(page);
    else if (controllers[index].hasClients) controllers[index].jumpTo(1);
  }
}
