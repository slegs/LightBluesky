import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/partials/actor.dart';

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
    try {
      final res = await api.c.actor.searchActorsTypeahead(
        term: term,
      );

      setState(() {
        actors = res.data.actors;
      });
    } on XRPCException catch (e) {
      if (!mounted) return;
      Ui.snackbar(context, e.toString());
    }
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
                return Actor(
                  actor: actors[i],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
