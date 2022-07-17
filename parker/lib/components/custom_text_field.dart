import 'package:flutter/material.dart';
import 'package:parker/constants.dart';

class CustomTextField extends StatelessWidget {
  /// custom text field for app

  const CustomTextField({
    Key? key,
    this.obscureText = false,
    this.rightPadding = 20.0,
    this.leftPadding = 20.0,
    this.iconButton,
    this.hintText,
    this.textFieldInput,
    this.customValidator,
    this.textController,
  }) : super(key: key);

  final TextInputType? textFieldInput;
  final TextEditingController? textController;
  final String? hintText;
  final bool obscureText; // for password text field
  final IconButton? iconButton; // for password field visibility icon
  final double rightPadding;
  final double leftPadding;
  final dynamic customValidator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: rightPadding, left: leftPadding),
      child: TextFormField(
        obscureText: obscureText,
        keyboardType: textFieldInput,
        controller: textController,
        validator: customValidator,
        decoration: kTextFieldDecoration.copyWith(
          suffixIcon: iconButton,
          hintText: hintText,
        ),
      ),
    );
  }
}
