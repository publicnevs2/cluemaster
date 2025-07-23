// lib/features/admin/admin_hunt_list_screen.dart

import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import 'admin_dashboard_screen.dart';
import 'admin_change_password_screen.dart';

class AdminHuntListScreen extends StatefulWidget {
  const AdminHuntListScreen({super.key});

  @override
  State<AdminHuntListScreen> createState() => _AdminHuntListScreenState();
}

class _AdminHuntListScreenState extends State<AdminHuntListScreen> {
  final ClueService _clueService = ClueService();
  List<Hunt> _hunts = [];

  @override
  void initState() {
    super.initState();
    _loadHunts();
  }

  Future<void> _loadHunts() async {
    final loadedHunts = await _clueService.loadHunts();
    if (mounted) {
      setState(() => _hunts = loadedHunts);
    }
  }

  Future<void> _createNewHunt() async {
    final huntNameController = TextEditingController();
    final newHuntName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neue Schnitzeljagd erstellen'),
        content: TextField(
          controller: huntNameController,
          decoration: const InputDecoration(hintText: "Name der Jagd"),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          TextButton(
            onPressed: () {
              if (huntNameController.text.trim().isNotEmpty) {
                Navigator.pop(context, huntNameController.text.trim());
              }
            },
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );

    if (newHuntName != null) {
      if (_hunts
          .any((hunt) => hunt.name.toLowerCase() == newHuntName.toLowerCase())) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Eine Jagd mit diesem Namen existiert bereits.'),
              backgroundColor: Colors.red),
        );
        return;
      }

      final newHunt = Hunt(name: newHuntName, clues: {});
      _hunts.add(newHunt);
      await _clueService.saveHunts(_hunts);
      _loadHunts();
    }
  }

  void _editHunt(Hunt hunt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboardScreen(hunt: hunt),
      ),
    ).then((_) => _loadHunts());
  }

  Future<void> _deleteHunt(Hunt huntToDelete) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Jagd löschen?'),
              content: Text(
                  'Möchtest du die Schnitzeljagd "${huntToDelete.name}" wirklich endgültig löschen?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Abbrechen')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Löschen')),
              ],
            ));

    if (confirm == true) {
      _hunts.removeWhere((hunt) => hunt.name == huntToDelete.name);
      await _clueService.saveHunts(_hunts);
      _loadHunts();
    }
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
        const SnackBar(
            content: Text('Fehler: Eine Jagd mit diesem Namen existiert bereits.'),
            backgroundColor: Colors.orange),
      );
    } else if (result == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fehler: Die Datei konnte nicht importiert werden. Bitte stelle sicher, dass es eine gültige .cluemaster-Datei ist.'),
            backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Die Jagd "$result" wurde erfolgreich importiert.'),
            backgroundColor: Colors.green),
      );
      _loadHunts();
    }
  }

  Future<void> _exportHuntWithFeedback(Hunt hunt) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${hunt.name}" wird zum Teilen vorbereitet...'),
        duration: const Duration(seconds: 4),
      ),
    );

    try {
      await _clueService.exportHunt(hunt, context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Exportieren: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Schnitzeljagden'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Jagd importieren',
            onPressed: _importHunt,
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Passwort ändern',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminChangePasswordScreen()),
              );
            },
          ),
        ],
      ),
      body: _hunts.isEmpty
          ? const Center(
              child: Text(
                  'Keine Schnitzeljagden gefunden. Erstelle oder importiere eine neue!'),
            )
          : ListView.builder(
              itemCount: _hunts.length,
              itemBuilder: (context, index) {
                final hunt = _hunts[index];
                return ListTile(
                  title: Text(hunt.name),
                  subtitle: Text('${hunt.clues.length} Stationen'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.blue),
                        tooltip: 'Jagd teilen/exportieren',
                        onPressed: () => _exportHuntWithFeedback(hunt),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Stationen bearbeiten',
                        onPressed: () => _editHunt(hunt),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Jagd löschen',
                        onPressed: () => _deleteHunt(hunt),
                      ),
                    ],
                  ),
                  onTap: () => _editHunt(hunt),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewHunt,
        label: const Text('Neue Jagd'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
