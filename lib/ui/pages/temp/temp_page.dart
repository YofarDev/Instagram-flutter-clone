import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:instagram_clone/services/database/user_services.dart';
import 'package:instagram_clone/ui/pages/tab5_user/animated_drawer.dart';
import 'package:instagram_clone/ui/pages/temp/switch_test.dart';
import 'package:pop_bottom_menu/pop_bottom_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TempPage extends StatefulWidget {
  TempPage({Key key}) : super(key: key);

  @override
  _TempPageState createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> with TickerProviderStateMixin {
  AnimationController _controller;
  String id = "";
  String test = "";
  var key = GlobalKey<ScaffoldState>();
  var drawerKey = GlobalKey<AnimatedDrawerState>();

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      elevation: 1,
    );
    return Scaffold(
      appBar: appBar,
      body: _child(),
    );
  }

  Widget _child() => Padding(
        padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.red,
              child: FlatButton(
                child: Text("Log out"),
                onPressed: () {
                  fb.FirebaseAuth.instance.signOut();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(id),
            ),
            Container(
              color: Colors.yellow,
              width: double.infinity,
              child: FlatButton(
                child: Text("Display current user ID"),
                onPressed: () {
                  setState(() {
                    id = UserServices.currentUserId;
                  });
                },
              ),
            ),
            Container(height: 20),
            Container(
                color: Colors.green,
                width: double.infinity,
                child: FlatButton(
                    onPressed: () => _showMenu(), child: Text("Pop Menu"))),
            Container(height: 20),
            Container(
              width: double.infinity,
              color: Colors.blue,
              child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SwitchTest(),
                    ));
                  },
                  child: Text("Images test")),
            ),
            Container(height: 20),
            Container(
              width: double.infinity,
              color: Colors.orange,
              child: FlatButton(
                  onPressed: () => _openDrawer(), child: Text("Drawer")),
            ),
            Container(height: 20),
            Container(
              width: double.infinity,
              color: Colors.cyan,
              child: FlatButton(
                  onPressed: () => _doSomething(), child: Text("Test")),
            ),
          ],
        ),
      );

  void _doSomething() async {
    var key = "OOOOH";
    var prefs = await SharedPreferences.getInstance();
    List<String> list = ["oui", "non"];
    prefs.setStringList(key, list);
    prefs = await SharedPreferences.getInstance();
    var a = prefs.getStringList(key);
    print(a[1]);
  }

  _showMenu() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return PopBottomMenu(
          title: TitlePopBottomMenu(
            label: "yofaraway",
          ),
          items: [
            ItemPopBottomMenu(
              onPressed: () => print("friend list"),
              label: "Add to Close Friends List",
              icon: Icon(
                Icons.star,
                color: Colors.grey,
              ),
            ),
            ItemPopBottomMenu(
              onPressed: () => print("notifications"),
              label: "Notifications",
              icon: Icon(
                Icons.navigate_next,
                color: Colors.grey,
              ),
            ),
            ItemPopBottomMenu(
              onPressed: () => print("mute"),
              label: "Mute",
              icon: Icon(
                Icons.navigate_next,
                color: Colors.grey,
              ),
            ),
            ItemPopBottomMenu(
              onPressed: () => print("restric"),
              label: "Restrict",
              icon: Icon(
                Icons.navigate_next,
                color: Colors.grey,
              ),
            ),
            ItemPopBottomMenu(
              onPressed: () => print("unfollow"),
              label: "Unfollow",
            ),
          ],
        );
      },
    );
  }

  void _openDrawer() {
    drawerKey.currentState.onDrawerIconTap();
  }
}
