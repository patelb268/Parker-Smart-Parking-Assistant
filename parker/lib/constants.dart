import 'package:flutter/material.dart';

/// this file is styling of the app

// common style
const kDarkTextColor = Colors.black54;
const kLightTextColor = Color(0xFFF2F9F1);
const kDarkColor = Color(0xFF388E3C);
const kHeaderTextStyle = TextStyle(
  color: kDarkTextColor,
  fontSize: 35.0,
  fontWeight: FontWeight.w500,
);

// style for toast
const kToastBackColor = Color(0xFFDDEEDF);

// style for Intro screen
const kIntroImageBorderRadius = BorderRadius.only(
  topRight: Radius.zero,
  topLeft: Radius.zero,
  bottomRight: Radius.circular(35.0),
  bottomLeft: Radius.circular(35.0),
);
const kIntroButtonTextStyle = TextStyle(
  color: Colors.black54,
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
);

// style for custom button title text
TextStyle kButtonTextStyle = const TextStyle(
  color: kLightTextColor,
  fontSize: 17.0,
  fontWeight: FontWeight.bold,
);

// style for custom button
BoxDecoration kButtonBoxDecoration = BoxDecoration(
  color: const Color(0xFF388E3C),
  border: Border.all(
    color: const Color(0xFF388E3C),
    width: 1,
  ),
  borderRadius: const BorderRadius.all(
    Radius.circular(15.0),
  ),
);

// style for custom text field
const kTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 15.0,
  ),
  suffixStyle: TextStyle(),
  hintText: 'Enter a value',
  hintStyle: TextStyle(
    color: Colors.black26,
  ),
  filled: true,
  fillColor: Colors.white,
  focusColor: Colors.black12,
  border: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
    ),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
    ),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
    ),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
);
