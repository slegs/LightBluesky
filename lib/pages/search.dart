import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isLoading = false;

  List<bsky.ActorBasic> actors = List.empty(
    growable: true,
  );

  @override
  void initState() {
    super.initState();
  }

  Future<void> _makeSearch(String term) async {
    final res = await api.actor.searchActorsTypeahead(
      term: term,
    );

    setState(() {
      actors = res.data.actors;
    });
  }

  void _handleSearch(String term) {
    setState(() {
      _isLoading = true;
    });

    _makeSearch(term);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Search"),
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (val) {
              _handleSearch(val);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Query',
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: actors.length,
              itemBuilder: (context, i) {
                return ListTile(
                  onTap: () {
                    Ui.nav(context, ProfilePage(did: actors[i].did));
                  },
                  leading: CircleAvatar(
                    backgroundImage: actors[i].avatar != null
                        ? NetworkImage(actors[i].avatar!)
                        : null,
                  ),
                  title: Text(actors[i].displayName != null
                      ? actors[i].displayName!
                      : '@${actors[i].handle}'),
                  subtitle: actors[i].displayName != null
                      ? Text('@${actors[i].handle}')
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
