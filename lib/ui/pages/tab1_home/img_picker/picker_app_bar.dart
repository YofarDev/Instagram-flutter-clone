import 'package:flutter/material.dart';
import 'package:instagram_clone/res/strings.dart';

class PickerAppBar extends StatelessWidget {
  final Function() onNextTap;

  PickerAppBar(this.onNextTap);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      title: Text(
        AppStrings.newPost,
        style: TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.clear,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.blue,
            ),
            onPressed: ()=> onNextTap())
      ],
    );
  }
}
