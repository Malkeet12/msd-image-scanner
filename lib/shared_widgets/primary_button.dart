import 'package:flutter/material.dart';
import 'package:image_scanner/theme/style.dart';

/*
-------Usage---------
PrimaryButton(
          text: 'Register',
          disabled: true, //optional
          onPressed: _onPressed,
        ),
*/

class PrimaryButton extends StatelessWidget {
  final String text;
  final bool disabled;
  final Function onPressed;
  final dynamic width;

  PrimaryButton({
    @required this.text,
    @required this.onPressed,
    this.width,
    this.disabled = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: disabled ? null : onPressed ?? () => {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: 42.0,
        width: 160.0,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: ColorShades.textPrimaryDark,
              offset: Offset(-7, -7),
              blurRadius: 20,
            )
          ],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: ColorShades.textSecGray3, width: 3.0),
        ),
        child: Center(
          child: Text(
            text,
            style: textTheme.h4.copyWith(color: ColorShades.textPrimaryLight),
          ),
        ),
      ),
    );
  }
}

class Btn extends StatelessWidget {
  const Btn({
    Key key,
    @required this.colorScheme,
    @required this.text,
    @required this.disabled,
    @required this.onPressed,
  }) : super(key: key);

  final ColorScheme colorScheme;
  final String text;
  final bool disabled;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: ColorShades.textSecNeon,
      disabledColor: ColorShades.disabled,
      textColor: ColorShades.textPrimaryLight,
      disabledTextColor: ColorShades.textSecGray3,
      highlightColor: ColorShades.hover,
      child: Text(
        text,
        style: Theme.of(context).textTheme.body1Medium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      onPressed: disabled ? null : onPressed ?? () => {},
    );
  }
}
