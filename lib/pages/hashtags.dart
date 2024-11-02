import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/hashtag.dart';

class HashtagsPage extends StatefulWidget {
  const HashtagsPage({super.key});

  @override
  State<HashtagsPage> createState() => _HashtagsPageState();
}

class _HashtagsPageState extends State<HashtagsPage> {
  @override
  Widget build(BuildContext context) {
    final hashtags = prefs.getStringList('hashtags') ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Hashtags"),
      ),
      body: hashtags.isNotEmpty
          ? ListView.builder(
              itemCount: hashtags.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(hashtags[i]),
                  trailing: IconButton(
                    onPressed: () {
                      final hashtags = prefs.getStringList('hashtags');
                      if (hashtags == null) {
                        return;
                      }

                      hashtags.removeAt(i);

                      setState(() {
                        prefs.setStringList('hashtags', hashtags);
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
          : const Center(
              child: Text('Your saved hashtags will be shown here'),
            ),
    );
  }
}