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
      backgroundColor: ColorShades.backgroundColorPrimary,
      centerTitle: true,
      title: Text(
        text,
        style: TextStyle(
          color: ColorShades.textColorOffWhite,
        ),
      ),
      leading: hideBack != true
          ? GestureDetector(
              onTap: onBackTap != null ? onBackTap : () {},
              child: Container(
                margin: EdgeInsets.all(5.0),
                decoration: new BoxDecoration(
                  color: Color.fromRGBO(33, 35, 39, 1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: Color.fromRGBO(102, 106, 110, 1),
                  size: 36.0,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(48.0);
}
