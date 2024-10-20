import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';

class ApiError extends StatelessWidget {
  const ApiError({super.key, required this.exception});

  final XRPCError exception;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error),
          Text('${exception.error}: ${exception.message}'),
        ],
      ),
    );
  }
}
