// lib/features/clue/clue_list_screen.dart

import 'package:clue_master/features/home/home_screen.dart';
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
    final viewedEntries = widget.hunt.clues.entries
        .where((entry) => entry.value.hasBeenViewed)
        .toList()
      // =======================================================
      // NEUE SORTIERUNG: Nach Zeitstempel statt nach Code
      // =======================================================
      ..sort((a, b) {
        final timeA = a.value.viewedTimestamp ?? DateTime(1970); // Fallback für alte Daten
        final timeB = b.value.viewedTimestamp ?? DateTime(1970);
        return timeA.compareTo(timeB);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Missions-Logbuch')),
      body: viewedEntries.isEmpty
          ? const Center(child: Text('Noch keine Hinweise gefunden.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                        leadingIcon = Icons.extension_outlined;
                      }

                      Widget subtitleWidget;
                      final originalSubtitleText = Text(
                        clue.question ?? clue.description ?? clue.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );

                      if (clue.solved &&
                          clue.nextClueCode != null &&
                          clue.nextClueCode!.isNotEmpty) {
                        subtitleWidget = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            originalSubtitleText,
                            const SizedBox(height: 4),
                            Text(
                              'Nächster Code: ${clue.nextClueCode}',
                              style: TextStyle(
                                  color: Colors.amber[300],
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        );
                      } else {
                        subtitleWidget = originalSubtitleText;
                      }

                      return ListTile(
                        leading: Icon(
                          leadingIcon,
                          color: clue.solved ? Colors.greenAccent : Colors.white,
                        ),
                        title: Text('Code: $code'),
                        subtitle: subtitleWidget,
                        trailing: clue.solved
                            ? const Icon(Icons.check_circle,
                                color: Colors.greenAccent)
                            : (clue.isRiddle
                                ? const Icon(Icons.lock_open_outlined)
                                : null),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil(
                          ModalRoute.withName(HomeScreen.routeName));
                    },
                    icon: const Icon(Icons.keyboard_outlined),
                    label: const Text('Neuen Code eingeben'),
                  ),
                ),
              ],
            ),
    );
  }
}
