import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  const IconText({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text),
          WidgetSpan(child: Icon(icon)),
        ],
      ),
    );
  }
}
