import 'package:flutter/material.dart';

class AlertDialogs extends StatelessWidget {
  /// dialog box for back button

  const AlertDialogs({required this.dialogAction, Key? key}) : super(key: key);

  final List<Widget> dialogAction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFDDEEDF),
      title: const Text('Are you sure?'),
      content: const Text('Do you want to exit scanner?'),
      actions: dialogAction,
    );
  }
}
