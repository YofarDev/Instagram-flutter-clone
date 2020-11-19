import 'package:flutter/material.dart';
import 'package:instagram_clone/temp_fake_data.dart';

class ReelsPage extends StatefulWidget {
  ReelsPage({Key key}) : super(key: key);

  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        child: Text("Test"),
        onPressed: () {
          FakeData.populateDb();
          print("added");
        },
      ),
    );
  }
}
