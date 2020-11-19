import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: FractionalOffset.center,
      padding: const EdgeInsets.only(top: 10.0),
      child: CircularProgressIndicator(),
    );
  }
}
