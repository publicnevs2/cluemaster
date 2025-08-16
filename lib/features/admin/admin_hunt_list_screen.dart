// lib/features/admin/admin_hunt_list_screen.dart

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import 'admin_dashboard_screen.dart';
import 'admin_change_password_screen.dart';
import 'admin_hunt_settings_screen.dart';
import 'admin_global_item_list_screen.dart'; // NEUER IMPORT

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

  Future<void> _navigateToHuntSettings(Hunt? hunt) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminHuntSettingsScreen(
          hunt: hunt,
          existingHuntNames: _hunts
              .where((h) => h.name != hunt?.name)
              .map((h) => h.name)
              .toList(),
        ),
      ),
    );

    if (result == true) {
      _loadHunts();
    }
  }

  void _navigateToDashboard(Hunt hunt) {
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const AutoSizeText(
            'Admin-Zentrale',
            maxLines: 1,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.construction_outlined),
              tooltip: 'Globale Werkzeugkiste',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminGlobalItemListScreen()),
                );
              },
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
        body: Column(
          children: [
            // ============================================================
            // NEU: Karte für Import/Export
            // ============================================================
            Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(Icons.import_export, color: Colors.cyan),
                title: const Text('Schnitzeljagd importieren'),
                subtitle: const Text('Eine .cluemaster-Datei laden'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _importHunt,
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
             Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.explore_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Meine Schnitzeljagden',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _hunts.isEmpty
                  ? const Center(
                      child: Text(
                          'Keine Schnitzeljagden gefunden. Erstelle eine neue!'),
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
                                icon: const Icon(Icons.settings),
                                tooltip: 'Jagd-Einstellungen (Name, Briefing)',
                                onPressed: () => _navigateToHuntSettings(hunt),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                tooltip: 'Stationen bearbeiten',
                                onPressed: () => _navigateToDashboard(hunt),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Jagd löschen',
                                onPressed: () => _deleteHunt(hunt),
                              ),
                            ],
                          ),
                          onTap: () => _navigateToDashboard(hunt),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToHuntSettings(null),
          label: const Text('Neue Jagd'),
          icon: const Icon(Icons.add),
        ),
      ), 
    );
  }
}
