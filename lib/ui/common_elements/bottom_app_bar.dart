import 'package:flutter/material.dart';
import 'package:instagram_clone/res/colors.dart';

class MyBottomAppBar extends StatelessWidget {
  final int currentPage;
  final Function(int) onPageChange;
  final bool darkTheme;

  MyBottomAppBar(
      {@required this.currentPage,
      @required this.onPageChange,
      @required this.darkTheme});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: (darkTheme) ? Colors.black : Colors.white,
      child: Stack(
        children: [
          Container(height: 1, color: AppColors.grey1010),
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
        child: IconButton(
          icon: (currentPage == 0)
              ? Icon(
                  Icons.home,
                  color: _getColor(),
                )
              : Icon(
                  Icons.home_outlined,
                  color: _getColor(),
                ),
          onPressed: () => onTabPressed(0),
        ),
      ),
      GestureDetector(
        child: IconButton(
          icon: (currentPage == 1)
              ? Icon(
                  Icons.pageview,
                  color: _getColor(),
                )
              : Icon(
                  Icons.search_outlined,
                  color: _getColor(),
                ),
          onPressed: () => onTabPressed(1),
        ),
      ),
      IconButton(
        icon: (currentPage == 2)
            ? Icon(
                Icons.video_collection,
                color: _getColor(),
              )
            : Icon(
                Icons.video_collection_outlined,
                color: _getColor(),
              ),
        onPressed: () => onTabPressed(2),
      ),
      IconButton(
        icon: (currentPage == 3)
            ? Icon(
                Icons.shop,
                color: _getColor(),
              )
            : Icon(
                Icons.shop_outlined,
                color: _getColor(),
              ),
        onPressed: () => onTabPressed(3),
      ),
      GestureDetector(
        child: IconButton(
          icon: (currentPage == 4)
              ? Icon(
                  Icons.account_circle,
                  color: _getColor(),
                )
              : Icon(
                  Icons.account_circle_outlined,
                  color: _getColor(),
                ),
          onPressed: () => onTabPressed(4),
        ),
      )
    ];
  }

  Color _getColor() => (darkTheme) ? Colors.white : Colors.black;

  void onTabPressed(int n) {
    onPageChange(n);
  }
}
