import 'package:flutter/material.dart';

class Nav {
  static void push(BuildContext context, Widget route) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => route),
    );
  }
}
