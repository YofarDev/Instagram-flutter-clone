import 'package:flutter/material.dart';

class InvertedCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval( Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width * 0.5))
      ..addRect( Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}