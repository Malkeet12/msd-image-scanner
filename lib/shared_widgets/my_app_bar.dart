import 'package:flutter/material.dart';
import 'package:image_scanner/theme/style.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  final onBackTap;
  final text;
  final hideBack;
  MyAppBar({
    Key key,
    @required this.text,
    this.hideBack,
    this.onBackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Colors.deepOrange,
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
