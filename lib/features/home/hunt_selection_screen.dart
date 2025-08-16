// lib/features/home/hunt_selection_screen.dart

// ignore_for_file: use_build_context_synchronously

import 'package:auto_size_text/auto_size_text.dart';
import 'package:clue_master/data/models/hunt_progress.dart';
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import 'home_screen.dart';
import '../admin/admin_login_screen.dart';
import 'briefing_screen.dart';
import '../clue/statistics_screen.dart';
import '../shared/about_screen.dart';

class HuntSelectionScreen extends StatefulWidget {
  const HuntSelectionScreen({super.key});

  @override
  State<HuntSelectionScreen> createState() => _HuntSelectionScreenState();
}

class _HuntSelectionScreenState extends State<HuntSelectionScreen> {
  final ClueService _clueService = ClueService();
  List<Hunt> _hunts = [];
  
  // ============================================================
  // NEU: Speichert die laufenden Spielstände
  // ============================================================
  Map<String, HuntProgress> _ongoingProgress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    // Lade beides: die Jagden und die laufenden Spielstände
    final loadedHunts = await _clueService.loadHunts();
    final loadedProgress = await _clueService.loadOngoingProgress();
    if (mounted) {
      setState(() {
        _hunts = loadedHunts;
        _ongoingProgress = loadedProgress;
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // ANGEPASST: Nimmt jetzt einen HuntProgress entgegen
  // ============================================================
  void _navigateToGame(Hunt hunt, HuntProgress progress) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: HomeScreen.routeName),
        builder: (_) {
          // Das Briefing wird nur beim allerersten Start gezeigt
          if (hunt.briefingText != null &&
              hunt.briefingText!.trim().isNotEmpty &&
              progress.startTime == null) {
            return BriefingScreen(hunt: hunt);
          } else {
            return HomeScreen(
              hunt: hunt,
              huntProgress: progress,
            );
          }
        },
      ),
    );
    // Lade die Daten neu, falls sich der Fortschritt geändert hat
    _loadData();
  }

  // ============================================================
  // KOMPLETT ÜBERARBEITET: Die Kernlogik für das Fortsetzen
  // ============================================================
  void _selectHunt(Hunt hunt) async {
    // Prüft, ob ein gespeicherter Spielstand für diese Jagd existiert
    final savedProgress = _ongoingProgress[hunt.name];

    if (savedProgress != null) {
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mission fortsetzen?'),
          content: const Text(
              'Du hast bei dieser Jagd bereits Fortschritt erzielt. Möchtest du weiterspielen oder von vorne beginnen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'continue'),
              child: const Text('Fortsetzen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'reset'),
              child: const Text('Neu starten'),
            ),
          ],
        ),
      );

      if (choice == 'reset') {
        // Entferne den alten Spielstand
        _ongoingProgress.remove(hunt.name);
        await _clueService.saveOngoingProgress(_ongoingProgress);
        // Setze die Hinweise in der Jagd-Datei zurück
        await _clueService.resetHuntProgress(hunt);
        final allHunts = await _clueService.loadHunts();
        final freshHunt = allHunts.firstWhere((h) => h.name == hunt.name);
        // Erstelle einen komplett neuen, leeren Fortschritt
        final newProgress = HuntProgress(
          huntName: freshHunt.name,
          collectedItemIds: Set<String>.from(freshHunt.startingItemIds),
        );
        _navigateToGame(freshHunt, newProgress);

      } else if (choice == 'continue') {
        // Lade den gespeicherten Fortschritt und starte das Spiel
        _navigateToGame(hunt, savedProgress);
      }
    } else {
      // Kein Fortschritt vorhanden, starte ein neues Spiel
      final newProgress = HuntProgress(
        huntName: hunt.name,
        collectedItemIds: Set<String>.from(hunt.startingItemIds),
      );
      _navigateToGame(hunt, newProgress);
    }
  }

  Future<void> _importHunt() async {
    final result = await _clueService.importHunt();
    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import abgebrochen.')),
      );
    } else if (result == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fehler: Die Datei konnte nicht importiert werden.'),
            backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Die Jagd "$result" wurde erfolgreich importiert.'),
            backgroundColor: Colors.green),
      );
      _loadData();
    }
  }

  void _navigateToAdmin() async {
    final refreshIsNeeded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );

    if (refreshIsNeeded == true && mounted) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText(
          'Schnitzeljagd auswählen',
          maxLines: 1,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Liste neu laden',
            onPressed: () {
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Liste wurde aktualisiert.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Meine Erfolge',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Über diese App',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin-Bereich',
            onPressed: _navigateToAdmin,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hunts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Keine Schnitzeljagden verfügbar. Bitte importiere eine .cluemaster Datei.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _hunts.length,
                  itemBuilder: (context, index) {
                    final hunt = _hunts[index];
                    return ListTile(
                      title: Text(hunt.name),
                      subtitle: Text('${hunt.clues.length} Stationen'),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => _selectHunt(hunt),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importHunt,
        label: const Text('Jagd importieren'),
        icon: const Icon(Icons.file_download),
      ),
    );
  }
}
