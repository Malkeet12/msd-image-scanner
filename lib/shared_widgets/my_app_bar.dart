import 'package:flutter/material.dart';
import 'package:image_scanner/theme/style.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  final onBackTap;
  final text;
  final hideBack;
  final color;
  MyAppBar({
    Key key,
    @required this.text,
    this.hideBack,
    this.onBackTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: color == null ? Colors.deepOrange : color,
      centerTitle: true,
      title: Text(
        text,
        style: TextStyle(
          color: ColorShades.textColorOffWhite,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(48.0);
}
