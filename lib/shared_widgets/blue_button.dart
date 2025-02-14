import 'package:flutter/material.dart';
import 'package:image_scanner/theme/style.dart';

class BlueButton extends StatelessWidget {
  final String text;
  final bool disabled;
  final Function onPressed;
  final dynamic width;

  BlueButton({
    @required this.text,
    @required this.onPressed,
    this.width,
    this.disabled = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.0,
      width: width ?? null,
      decoration: BoxDecoration(
        boxShadow: [],
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: RaisedButton(
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Color(0xff4364A1),
        disabledColor: ColorShades.disabled,
        textColor: ColorShades.textPrimaryLight,
        disabledTextColor: ColorShades.textSecGray3,
        highlightColor: ColorShades.hover,
        child: Text(
          text,
          style: Theme.of(context).textTheme.h4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        onPressed: disabled ? null : onPressed ?? () => {},
      ),
    );
  }
}
