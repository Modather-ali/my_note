import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    fontFamily: 'Karla-Light',
  ).copyWith(
    textTheme: TextTheme(
      headline1: TextStyle(color: Colors.black),
      bodyText1: TextStyle(
        color: Colors.blue,
        fontSize: 16,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFFF4cc9f0),
      secondary: Color(0xFFF72efdd),
    ),
  );
}
