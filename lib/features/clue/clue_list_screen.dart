// lib/features/clue/clue_list_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/hunt.dart';
import 'clue_detail_screen.dart'; 

class ClueListScreen extends StatefulWidget {
  final Hunt hunt;
  const ClueListScreen({super.key, required this.hunt});

  @override
  State<ClueListScreen> createState() => _ClueListScreenState();
}

class _ClueListScreenState extends State<ClueListScreen> {
  @override
  Widget build(BuildContext context) {
    final solvedEntries =
        widget.hunt.clues.entries.where((entry) => entry.value.solved).toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(title: const Text('Gefundene Hinweise')),
      body: solvedEntries.isEmpty
          ? const Center(child: Text('Noch keine Hinweise gefunden.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: solvedEntries.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final code = solvedEntries[index].key;
                final clue = solvedEntries[index].value;

                return ListTile(
                  leading: Icon(
                    clue.type == 'text' ? Icons.text_fields : Icons.image,
                    color: Colors.green,
                  ),
                  title: Text('Code: $code'),
                  subtitle: Text(clue.isRiddle ? clue.question! : clue.content),
                  trailing:
                      const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClueDetailScreen(hunt: widget.hunt, clue: clue),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}