import 'package:flutter/material.dart';

class Dialogues {
  static successDialogue(context, title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(title),
      backgroundColor: Colors.green.shade400,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static errorDialogue(context, title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(title),
      backgroundColor: Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
