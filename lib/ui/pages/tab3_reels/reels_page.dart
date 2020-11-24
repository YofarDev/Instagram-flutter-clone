import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/services/publication_services.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/ui/pages/tab3_reels/switch_test.dart';

class ReelsPage extends StatefulWidget {
  ReelsPage({Key key}) : super(key: key);

  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  String id = "";
  String test = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  id = UserServices.currentUser;
                });
              },
            ),
          ),
          Container(padding: EdgeInsets.all(20), child: Text(test)),
          Container(
              color: Colors.green,
              width: double.infinity,
              child: FlatButton(
                  onPressed: () => doSomething(), child: Text("Test"))),
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
          )
        ],
      ),
    );
  }

  doSomething() async {
User u = await UserServices.getCurrentUser();
u.username = "oui";
u.name = "non";
await UserServices.updateUserProfile(u);
u = await UserServices.getCurrentUser();
    setState(() {
      test = "${u.username} et ${u.name}";
    });
  }
}
