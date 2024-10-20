import 'dart:convert';

import 'package:bluesky/atproto.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/home.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();

  void handleSession() async {
    final session = await createSession(
      identifier: _identityController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    try {
      // Save to memory and to local disk
      final data = session.data.toJson();
      api = Bluesky.fromSession(session.data);
      prefs.setString('session', json.encode(data));

      // Redirect to home
      Ui.nav(context, const HomePage());
    } on XRPCException catch (e) {
      // Something went wrong
      Ui.snackbar(
        context,
        'Something went wrong! ${e.response.data.error}: ${e.response.data.message}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Auth"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _identityController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Handle / email',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            OutlinedButton(
              onPressed: handleSession,
              child: const Text(
                'Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
