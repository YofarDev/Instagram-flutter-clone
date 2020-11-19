import 'package:flutter/material.dart';

class EditAppBar extends StatelessWidget {
  final String title;
  final String inputText;

  EditAppBar(
      {@required this.title,
      @required this.inputText,
      });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      pinned: true,
      elevation: 1,
      leading: IconButton(
        icon: Icon(
          Icons.close,
          size: 40,
          color: Colors.black87,
        ),
        onPressed: () => {Navigator.of(context).pop()},
      ),
      title: SizedBox(
        height: 35,
        child: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),
        ),
      ),
      actions: [
        IconButton(
          padding: EdgeInsets.only(
            right: 30,
          ),
          icon: Icon(
            Icons.check,
            size: 40,
            color: Colors.blue,
          ),
          onPressed: () => {Navigator.of(context).pop(inputText)},
        ),
      ],
    );
  }
}
