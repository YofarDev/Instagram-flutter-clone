import 'package:flutter/material.dart';

class UserAppBar extends StatelessWidget {
  final String username;
  UserAppBar(this.username);
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      brightness: Brightness.light,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
      title: SizedBox(
        height: 35.0,
        child: Text(username,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            )),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.add,
            color: Colors.black,
          ),
          onPressed: null,
        ),
        IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: null,
        ),
      ],
    );
  }
}
