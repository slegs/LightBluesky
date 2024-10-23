import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isLoading = false;

  final _queryController = TextEditingController();

  void _handleSearch() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Search"),
      ),
      body: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Query',
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: !_isLoading ? _handleSearch : null,
            icon: const Icon(Icons.search),
            label: const Text(
              'Go',
            ),
          ),
        ],
      ),
    );
  }
}
