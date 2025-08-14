// lib/features/clue/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ClueService _clueService = ClueService();
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    // Lade beide Datenquellen gleichzeitig, um Wartezeiten zu optimieren
    _dataFuture = Future.wait([
      _clueService.loadHuntProgress(),
      _clueService.loadHunts(),
    ]);
  }

  // Hilfsfunktion zur Formatierung der Dauer in HH:mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Missions-Akte'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler beim Laden der Akte: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Keine Daten gefunden.'));
          }

          final List<HuntProgress> progressHistory = snapshot.data![0];
          final List<Hunt> allHunts = snapshot.data![1];

          if (progressHistory.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Du hast noch keine Missionen abgeschlossen. Deine Erfolge werden hier angezeigt.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ),
            );
          }

          // Gruppiere die Erfolge nach dem Namen der Jagd
          final Map<String, List<HuntProgress>> groupedProgress = {};
          for (var progress in progressHistory) {
            groupedProgress.putIfAbsent(progress.huntName, () => []).add(progress);
          }
          
          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: groupedProgress.entries.map((entry) {
              final huntName = entry.key;
              final progresses = entry.value;

              // Finde die beste Leistung (kürzeste Zeit) für diese Jagd
              progresses.sort((a, b) => a.duration.compareTo(b.duration));
              final bestProgress = progresses.first;
              
              final Hunt? huntData = allHunts.firstWhere(
                (h) => h.name == huntName,
                orElse: () => Hunt(name: huntName), // Fallback, falls Jagd gelöscht wurde
              );

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        huntName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        icon: Icons.emoji_events,
                        label: 'Bestzeit',
                        value: _formatDuration(bestProgress.duration),
                        iconColor: Colors.amber,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.error_outline,
                        label: 'Fehlversuche (beste Runde)',
                        value: bestProgress.failedAttempts.toString(),
                      ),
                       if (huntData?.targetTimeInMinutes != null) ...[
                        const SizedBox(height: 12),
                        _buildStatRow(
                          icon: Icons.timer_outlined,
                          label: 'Zielzeit',
                          value: '${huntData!.targetTimeInMinutes} Minuten',
                        ),
                       ],
                      const SizedBox(height: 12),
                       _buildStatRow(
                        icon: Icons.replay_outlined,
                        label: 'Absolvierte Missionen',
                        value: progresses.length.toString(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildStatRow({required IconData icon, required String label, required String value, Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}