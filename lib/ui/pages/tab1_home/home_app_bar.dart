import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(int) onIconTap;

  HomeAppBar({@required this.onIconTap});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: false,
      title: SizedBox(
        height: 35.0,
        child: Image.asset(
          "assets/images/insta_logo.png",
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.control_point,
            color: Colors.black,
          ),
          onPressed: ()=>onIconTap(0),
        ),
        IconButton(
          icon: Icon(
            Icons.favorite_border_outlined,
            color: Colors.black,
          ),
             onPressed: ()=>onIconTap(1),
        ),
        IconButton(
          icon: Icon(
            Icons.send_outlined,
            color: Colors.black,
          ),
            onPressed: ()=>onIconTap(2),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(66);
}
