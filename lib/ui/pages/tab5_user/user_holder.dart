import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/ui/pages/tab5_user/animated_drawer.dart';
import 'package:instagram_clone/ui/pages/tab5_user/current_user_page.dart';
import 'package:instagram_clone/ui/pages/tab5_user/user_page.dart';
import 'package:instagram_clone/ui/pages/temp/temp_page.dart';

class UserHolder extends StatefulWidget {
  final bool isCurrent;
  final User user;

  UserHolder({this.isCurrent, this.user});

  @override
  _UserHolderState createState() => _UserHolderState();
}

class _UserHolderState extends State<UserHolder> {
  final GlobalKey<AnimatedDrawerState> key = GlobalKey<AnimatedDrawerState>();
  String username;

  @override
  void initState() {
    username = "";
    _getUsername();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (widget.isCurrent)
        ? AnimatedDrawer(
            key: key,
            title: username,
            items: _itemsDrawer(),
            child: CurrentUserPage(_onDrawerIconTap),
          )
        : UserPage(widget.user);
  }

  List<Widget> _itemsDrawer() => [
        Align(
          alignment: Alignment.centerLeft,
          child: FlatButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.bookmark_outline_sharp,
            ),
            label: Text(
              "Saved",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FlatButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TempPage(),
              ),
            ),
            icon: Icon(
              Icons.face_unlock_outlined,
            ),
            label: Text(
              "Page Temporaire",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ];

  void _onDrawerIconTap() => key.currentState.onDrawerIconTap();

  void _getUsername() async {
    User current = await UserServices.getCurrentUser();
    setState(() {
      username = current.username;
    });
  }
}
