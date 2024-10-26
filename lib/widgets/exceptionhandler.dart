import 'package:flutter/material.dart';

/// Shows a thrown exception
class ExceptionHandler extends StatelessWidget {
  const ExceptionHandler({super.key, required this.exception});

  final Object exception;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error),
          Text(exception.toString()),
        ],
      ),
    );
  }
}
