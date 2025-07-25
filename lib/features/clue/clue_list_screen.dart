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

                // --- NEUE LOGIK (Konzept 2.0): Icon basierend auf dem Rätsel-Typ ---
                IconData leadingIcon;
                if (clue.isGpsRiddle) {
                  // Wenn es ein GPS-Rätsel ist, zeige ein Standort-Icon
                  leadingIcon = Icons.location_on_outlined;
                } else if (clue.isRiddle) {
                  // Ansonsten das normale Rätsel-Icon
                  leadingIcon = Icons.question_answer_outlined;
                } else {
                  // Oder das "gesehen"-Icon für reine Hinweise
                  leadingIcon = Icons.visibility_outlined;
                }

                return ListTile(
                  leading: Icon(
                    leadingIcon,
                    color: clue.solved ? Colors.greenAccent : Colors.white,
                  ),
                  title: Text('Code: $code'),
                  subtitle: Text(
                    clue.question ?? clue.description ?? clue.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: clue.solved
                      ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                      : (clue.isRiddle ? const Icon(Icons.lock_open_outlined) : null),
                  onTap: () {
                    // --- VEREINFACHTE LOGIK (Konzept 2.0) ---
                    // Navigiere IMMER zum Detailbildschirm.
                    // Dieser entscheidet dann, was zu tun ist.
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
