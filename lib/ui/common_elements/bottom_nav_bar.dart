import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentPage;
  final Function(int) onPageChange;
  final Function(int, int) onDoubleTap;

  BottomNavBar({
    @required this.currentPage,
    @required this.onPageChange,
    @required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabsList(),
      ),
    );
  }

  List<Widget> tabsList() {
    return [
      GestureDetector(
        onDoubleTap: () => onDoubleTap(0, 0),
        child: IconButton(
          icon:
              (currentPage == 0) ? Icon(Icons.home) : Icon(Icons.home_outlined),
          onPressed: () => onTabPressed(0),
        ),
      ),
      GestureDetector(
        onDoubleTap: () => onDoubleTap(1, 1),
        child: IconButton(
          icon: (currentPage == 1)
              ? Icon(Icons.pageview)
              : Icon(Icons.search_outlined),
          onPressed: () => onTabPressed(1),
        ),
      ),
      IconButton(
        icon: (currentPage == 2)
            ? Icon(Icons.video_collection)
            : Icon(Icons.video_collection_outlined),
        onPressed: () => onTabPressed(2),
      ),
      IconButton(
        icon: (currentPage == 3) ? Icon(Icons.shop) : Icon(Icons.shop_outlined),
        onPressed: () => onTabPressed(3),
      ),
      GestureDetector(
        onDoubleTap: () => onDoubleTap(4, 2),
        child: IconButton(
          icon: (currentPage == 4)
              ? Icon(Icons.account_circle)
              : Icon(Icons.account_circle_outlined),
          onPressed: () => onTabPressed(4),
        ),
      )
    ];
  }

  void onTabPressed(int n) {
    onPageChange(n);
  }
}
