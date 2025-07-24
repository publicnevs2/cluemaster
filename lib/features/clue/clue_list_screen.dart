import 'package:flutter/material.dart';
import '../../data/models/clue.dart';
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
    // NEUE LOGIK (v1.43): Zeigt alle Hinweise an, die schon einmal gesehen wurden.
    final viewedEntries =
        widget.hunt.clues.entries.where((entry) => entry.value.hasBeenViewed).toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(title: const Text('Missions-Logbuch')),
      body: viewedEntries.isEmpty
          ? const Center(child: Text('Noch keine Hinweise gefunden.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewedEntries.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final code = viewedEntries[index].key;
                final clue = viewedEntries[index].value;

                return ListTile(
                  // NEUES ICON-SYSTEM (v1.43)
                  leading: Icon(
                    clue.isRiddle ? Icons.question_answer_outlined : Icons.visibility_outlined,
                    color: clue.solved ? Colors.greenAccent : Colors.white,
                  ),
                  title: Text('Code: $code'),
                  subtitle: Text(
                    clue.question ?? clue.description ?? clue.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // NEUES TRAILING-ICON (v1.43)
                  trailing: clue.solved
                      ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                      : (clue.isRiddle ? const Icon(Icons.lock_open_outlined) : null),
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
