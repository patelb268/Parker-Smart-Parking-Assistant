import 'package:flutter/material.dart';
import 'package:parker/constants.dart';

class CustomButton extends StatelessWidget {
  /// custom button widget for app

  const CustomButton({
    Key? key,
    this.buttonHeight,
    this.buttonWidth,
    this.title,
    this.textSize,
    this.buttonFunction,
  }) : super(key: key);

  final double? buttonWidth;
  final double? buttonHeight;
  final String? title; // title text
  final double? textSize; // title text size
  final VoidCallback? buttonFunction; // onPressed function

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: RawMaterialButton(
        onPressed: buttonFunction,
        child: Container(
          height: (buttonHeight == null) ? h * 0.05 : buttonHeight,
          width: buttonWidth,
          decoration: kButtonBoxDecoration, // button decoration
          child: Center(
            child: Text(
              '$title',
              style: kButtonTextStyle, // title text style
            ),
          ),
        ),
      ),
    );
  }
}
