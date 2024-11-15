import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/hashtag.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HashtagsPage extends StatefulWidget {
  const HashtagsPage({super.key});

  @override
  State<HashtagsPage> createState() => _HashtagsPageState();
}

class _HashtagsPageState extends State<HashtagsPage> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final hashtags = storage.hashtags.get();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(locale.hashtags_title),
      ),
      body: hashtags.isNotEmpty
          ? ListView.builder(
              itemCount: hashtags.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(hashtags[i]),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        storage.hashtags.remove(index: i);
                      });
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  onTap: () {
                    Ui.nav(
                      context,
                      HashtagPage(name: hashtags[i]),
                    );
                  },
                );
              },
            )
          : Center(
              child: Text(locale.hashtags_empty),
            ),
    );
  }
}
