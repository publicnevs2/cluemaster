// lib/features/home/hunt_selection_screen.dart

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import 'home_screen.dart';
import '../admin/admin_login_screen.dart';

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

  void _selectHunt(Hunt hunt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(hunt: hunt),
      ),
    ).then((_) {
      // Lädt die Daten neu, wenn man von einem Spiel zurückkehrt
      _loadHunts();
    });
  }

  Future<void> _importHunt() async {
    final result = await _clueService.importHunt();
    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import abgebrochen.')),
      );
    } else if (result == "EXISTS") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler: Eine Jagd mit diesem Namen existiert bereits.'), backgroundColor: Colors.orange),
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

  void _navigateToAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    ).then((_) {
      // Lädt die Daten neu, wenn man vom Admin-Bereich zurückkehrt
      _loadHunts();
    });
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
