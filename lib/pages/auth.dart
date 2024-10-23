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
  bool _isLoading = false;
  bool _needsFactor = false;

  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authFactorController = TextEditingController();

  void _handleSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final session = await createSession(
        identifier: _identityController.text,
        password: _passwordController.text,
        authFactorToken: _authFactorController.value.text != ''
            ? _authFactorController.value.text
            : null,
      );

      if (!mounted) return;
      // Save to memory and to local disk
      final data = session.data.toJson();
      api = Bluesky.fromSession(session.data);
      prefs.setString('session', json.encode(data));

      // Redirect to home
      Ui.nav(context, const HomePage());
    } on XRPCException catch (e) {
      // Something went wrong
      if (e.response.data.error == 'AuthFactorTokenRequired') {
        // Server is asking for 2FA
        Ui.snackbar(context, e.response.data.message);

        setState(() {
          _needsFactor = true;
          _isLoading = false;
        });
        return;
      }

      Ui.dialog(
        context,
        'Error ${e.response.data.error}',
        e.response.data.message,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
    }

    setState(() {
      _isLoading = false;
    });
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
            // 2FA field, hidden by default
            Visibility(
              visible: _needsFactor,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _authFactorController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '2FA code',
                  ),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: !_isLoading ? _handleSession : null,
              icon: const Icon(Icons.login),
              label: const Text(
                'Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
