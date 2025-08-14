// ignore_for_file: use_build_context_synchronously

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import 'home_screen.dart';
import '../admin/admin_login_screen.dart';
import 'briefing_screen.dart';

class HuntSelectionScreen extends StatefulWidget {
  const HuntSelectionScreen({super.key});

  @override
  State<HuntSelectionScreen> createState() => _HuntSelectionScreenState();
}

class _HuntSelectionScreenState extends State<HuntSelectionScreen> {
  final ClueService _clueService = ClueService();
  List<Hunt> _hunts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHunts();
  }

  // Diese Methode ist der Schlüssel zur Aktualisierung.
  Future<void> _loadHunts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final loadedHunts = await _clueService.loadHunts();
    if (mounted) {
      setState(() {
        _hunts = loadedHunts;
        _isLoading = false;
      });
    }
  }

  void _navigateToGame(Hunt hunt) async {
    // Navigiert zum Spiel (Briefing oder HomeScreen)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (hunt.briefingText != null && hunt.briefingText!.trim().isNotEmpty) {
            return BriefingScreen(hunt: hunt);
          } else {
            return HomeScreen(hunt: hunt);
          }
        },
      ),
    );
    
    // Nach der Rückkehr vom Spiel wird die Liste neu geladen,
    // um den Fortschritt korrekt anzuzeigen.
    _loadHunts();
  }

  void _selectHunt(Hunt hunt) async {
    final hasProgress = hunt.clues.values.any((clue) => clue.hasBeenViewed);

    if (hasProgress) {
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mission fortsetzen?'),
          content: const Text('Du hast bei dieser Jagd bereits Fortschritt erzielt. Möchtest du weiterspielen oder von vorne beginnen?'),
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
        await _clueService.resetHuntProgress(hunt);
        final allHunts = await _clueService.loadHunts();
        final freshHunt = allHunts.firstWhere((h) => h.name == hunt.name);
        _navigateToGame(freshHunt);
      } else if (choice == 'continue') {
        _navigateToGame(hunt);
      }
    } else {
      _navigateToGame(hunt);
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
        const SnackBar(content: Text('Fehler: Die Datei konnte nicht importiert werden.'), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Die Jagd "$result" wurde erfolgreich importiert.'), backgroundColor: Colors.green),
      );
      _loadHunts();
    }
  }

  // =======================================================
  // KORRIGIERTER TEIL: Automatischer Refresh
  // =======================================================
  void _navigateToAdmin() async {
    // Navigiere zum Admin-Login-Screen und WARTE auf eine Rückmeldung.
    final refreshIsNeeded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );

    // Wenn der Admin-Bereich mit `true` verlassen wird, lade die Jagden neu.
    if (refreshIsNeeded == true && mounted) {
      _loadHunts();
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
          // NEU: Manueller Refresh-Button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Liste neu laden',
            onPressed: () {
              _loadHunts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Liste wurde aktualisiert.'),
                  duration: Duration(seconds: 1),
                ),
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