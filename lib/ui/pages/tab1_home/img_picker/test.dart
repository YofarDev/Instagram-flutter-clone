import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Testo extends StatefulWidget {
 final Uint8List imageData;
  Testo(this.imageData);
  @override
  _TestoState createState() => _TestoState();
}

class _TestoState extends State<Testo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width,
      child: Image.memory(widget.imageData)
    );
  }
}
