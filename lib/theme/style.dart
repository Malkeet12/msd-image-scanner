import 'package:flutter/material.dart';

class ColorShades {
  static const backgroundColorPrimary = Color.fromRGBO(37, 39, 44, 1);
  static const textColorSecondary = Color.fromRGBO(115, 119, 122, 1);
  static const textColorOffWhite = Color.fromRGBO(243, 243, 244, 1);
  static const textPrimaryLight = const Color(0xffffffff);
  static const Color secondaryColorHover = const Color(0xff2c2c36);
  static const textPrimaryDark = const Color(0xff2d2d33);
  static const textSecGray2 = const Color(0xffb1bad4);
  static const textSecGray3 = const Color(0xff647093);
  static const textSecNeon = const Color(0xff426bff);
  static const hover = const Color(0xff3755c1);
  static const disabled = const Color(0xffd9dfee);
}

extension CustomTextTheme on TextTheme {
  TextStyle get h1 => TextStyle(
      fontSize: 28.0, fontWeight: FontWeight.w500, height: 28.0 / 28.0);
  TextStyle get h2 => TextStyle(
      fontSize: 24.0, fontWeight: FontWeight.w500, height: 24.0 / 24.0);
  TextStyle get h3 => TextStyle(
      fontSize: 20.0, fontWeight: FontWeight.w500, height: 24.0 / 20.0);
  TextStyle get h4 => TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.w500, height: 20.0 / 16.0);
  TextStyle get h5 => TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      height: 16.0 / 12.0,
      letterSpacing: 1.0);
  TextStyle get pageTitle => TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.w700, height: 20.0 / 16.0);
  TextStyle get body1Regular => TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w400, height: 18.0 / 14.0);
  TextStyle get body1Medium => TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w500, height: 18.0 / 14.0);
  TextStyle get body1Bold => TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w700, height: 18.0 / 14.0);
  TextStyle get body1Black => TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w900, height: 18.0 / 14.0);
  TextStyle get body2Regular => TextStyle(
      fontSize: 12.0, fontWeight: FontWeight.w400, height: 16.0 / 12.0);
  TextStyle get body2Medium => TextStyle(
      fontSize: 12.0, fontWeight: FontWeight.w500, height: 16.0 / 12.0);
  TextStyle get body2Bold => TextStyle(
      fontSize: 12.0, fontWeight: FontWeight.w700, height: 16.0 / 12.0);
  TextStyle get body2Italic => TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w700,
      height: 16.0 / 12.0,
      fontStyle: FontStyle.italic);
  TextStyle get formFieldText => TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.w400, letterSpacing: 2.0);
}
