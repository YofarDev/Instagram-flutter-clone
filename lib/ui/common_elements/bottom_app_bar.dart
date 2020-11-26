import 'package:flutter/material.dart';
import 'package:instagram_clone/res/colors.dart';

class MyBottomAppBar extends StatelessWidget {
  final int currentPage;
  final Function(int) onPageChange;
  final Function(int, int) onDoubleTap;

  MyBottomAppBar({
    @required this.currentPage,
    @required this.onPageChange,
    @required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      child: Stack(
        children: [
          Container(
            height: 1,
            color: AppColors.grey1010
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs(),
          ),
        ],
      ),
    );
  }

  List<Widget> _tabs() {
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
