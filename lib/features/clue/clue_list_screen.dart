import 'package:flutter/material.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';
import 'clue_detail_screen.dart';

class ClueListScreen extends StatefulWidget {
  final Hunt hunt;
  final HuntProgress huntProgress;

  const ClueListScreen({
    super.key,
    required this.hunt,
    required this.huntProgress,
  });

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

                IconData leadingIcon;
                switch (clue.type) {
                  case 'text':
                    leadingIcon = Icons.description_outlined;
                    break;
                  case 'image':
                    leadingIcon = Icons.image_outlined;
                    break;
                  case 'audio':
                    leadingIcon = Icons.audiotrack_outlined;
                    break;
                  case 'video':
                    leadingIcon = Icons.movie_outlined;
                    break;
                  default:
                    leadingIcon = Icons.visibility_outlined;
                }

                if (clue.isGpsRiddle) {
                  leadingIcon = Icons.location_on_outlined;
                } else if (clue.isRiddle) {
                  // ÄNDERUNG: Wir nehmen hier ein passenderes Icon für Rätsel
                  leadingIcon = Icons.extension_outlined; 
                }

                // =======================================================
                // NEU: Logik für den Untertitel
                // =======================================================
                Widget subtitleWidget;
                final originalSubtitleText = Text(
                  clue.question ?? clue.description ?? clue.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );

                if (clue.autoTriggerNextClue && clue.solved) {
                  subtitleWidget = Row(
                    children: [
                      Icon(Icons.double_arrow_rounded, color: Colors.amber[300], size: 16),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Führt automatisch weiter',
                          style: TextStyle(fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                } else {
                  subtitleWidget = originalSubtitleText;
                }
                // =======================================================


                return ListTile(
                  leading: Icon(
                    leadingIcon,
                    color: clue.solved ? Colors.greenAccent : Colors.white,
                  ),
                  title: Text('Code: $code'),
                  subtitle: subtitleWidget, // Hier das neue Widget einfügen
                  trailing: clue.solved
                      ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                      : (clue.isRiddle ? const Icon(Icons.lock_open_outlined) : null),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClueDetailScreen(
                          hunt: widget.hunt,
                          clue: clue,
                          huntProgress: widget.huntProgress,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}