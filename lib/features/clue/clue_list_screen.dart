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
                // KORREKTUR HIER: Logik für alle Hinweis-Typen
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
                    leadingIcon = Icons.movie_outlined; // Richtiges Icon für Video
                    break;
                  default:
                    leadingIcon = Icons.visibility_outlined;
                }
                
                // Überschreibe das Icon, wenn es ein Rätsel ist
                if (clue.isGpsRiddle) {
                  leadingIcon = Icons.location_on_outlined;
                } else if (clue.isRiddle) {
                  leadingIcon = Icons.movie_outlined;
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