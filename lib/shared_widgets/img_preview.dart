import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_scanner/theme/style.dart';

class ImgPreview extends StatelessWidget {
  const ImgPreview({
    Key key,
    @required this.path,
    this.margin,
    this.height,
  }) : super(key: key);

  final path;
  final height;
  final margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
      margin: margin ?? EdgeInsets.symmetric(horizontal: 20.0),
      width: double.infinity,
      height: height ?? 150,
      decoration: BoxDecoration(
        color: ColorShades.lightBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Image.file(
        File(
          path,
        ),
        fit: BoxFit.cover,
        // fit: BoxFit.cover,
        // width: double.maxFinite,
      ),
    );
  }
}
