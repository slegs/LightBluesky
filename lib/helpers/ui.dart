import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Ui helper class
class Ui {
  /// Opens a dialog modal.
  static Future<void> dialog(
    BuildContext context,
    String title,
    String body, {
    List<TextButton>? actions,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: actions,
        );
      },
    );
  }

  /// Opens a snackbar dialog.
  static void snackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  /// Opens a URL using the user's prefered browser.
  static Future<void> openUrl(String url) async {
    final ok = await launchUrlString(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      throw Exception('Could not launch $url');
    }
  }

  /// Open indent if on mobile or copy url to clipboard
  static Future<void> shareUrl(String url, BuildContext context) async {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      Share.shareUri(
        Uri.parse(url),
      );
      return;
    }

    Clipboard.setData(
      ClipboardData(text: url),
    );

    if (!context.mounted) return;

    snackbar(context, "Saved to clipboard");
  }
}
