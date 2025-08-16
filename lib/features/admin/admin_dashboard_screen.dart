// lib/features/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import 'admin_editor_screen.dart';
import 'admin_item_list_screen.dart';
import 'admin_geofence_list_screen.dart'; // NEUER IMPORT

class AdminDashboardScreen extends StatefulWidget {
  final Hunt hunt;

  const AdminDashboardScreen({super.key, required this.hunt});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ClueService _clueService = ClueService();
  late Hunt _currentHunt;

  @override
  void initState() {
    super.initState();
    _currentHunt = widget.hunt;
  }

  Future<void> _refreshHunt() async {
    final allHunts = await _clueService.loadHunts();
    if (mounted) {
      setState(() {
        _currentHunt = allHunts.firstWhere((h) => h.name == widget.hunt.name);
      });
    }
  }

  Future<void> _saveClueChanges(Map<String, Clue> updatedClues) async {
    final allHunts = await _clueService.loadHunts();
    final index = allHunts.indexWhere((h) => h.name == _currentHunt.name);
    if (index != -1) {
      allHunts[index].clues = updatedClues;
      await _clueService.saveHunts(allHunts);
      await _refreshHunt();
    }
  }

  Future<void> _deleteClue(String code) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: Text('Station "$code" wirklich löschen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (confirm == true) {
      final updatedClues = Map<String, Clue>.from(_currentHunt.clues)..remove(code);
      await _saveClueChanges(updatedClues);
    }
  }

  Future<void> _openEditor({String? codeToEdit}) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AdminEditorScreen(
            hunt: _currentHunt,
            codeToEdit: codeToEdit,
            existingClue: codeToEdit != null ? _currentHunt.clues[codeToEdit] : null,
            existingCodes: _currentHunt.clues.keys.toList(),
            onSave: (updatedMap) async {
              final updatedClues = Map<String, Clue>.from(_currentHunt.clues);
              if (codeToEdit != null && updatedMap.keys.first != codeToEdit) {
                updatedClues.remove(codeToEdit);
              }
              updatedClues.addAll(updatedMap);
              await _saveClueChanges(updatedClues);
            },
          );
        },
      ),
    );
  }

  Future<void> _resetProgress() async {
    // Hier wird der Fortschritt der Jagd zurückgesetzt (solved flags)
    final updatedClues = Map<String, Clue>.from(_currentHunt.clues);
    for (var clue in updatedClues.values) {
      clue.solved = false;
      clue.hasBeenViewed = false;
    }
    
    // Hier wird der Fortschritt der Geofences zurückgesetzt
    for (var trigger in _currentHunt.geofenceTriggers) {
      trigger.hasBeenTriggered = false;
    }

    await _saveClueChanges(updatedClues); // Diese Methode speichert die gesamte Jagd
     if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spielfortschritt wurde zurückgesetzt.'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _navigateToItemLibrary() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminItemListScreen(hunt: _currentHunt),
      ),
    );
    await _refreshHunt();
  }
  
  // ============================================================
  // NEU: Navigation zur Geofence-Verwaltung
  // ============================================================
  Future<void> _navigateToGeofenceTriggers() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminGeofenceListScreen(hunt: _currentHunt),
      ),
    );
    await _refreshHunt();
  }

  @override
  Widget build(BuildContext context) {
    final clues = _currentHunt.clues;
    final codes = clues.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard: ${_currentHunt.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Fortschritt zurücksetzen',
            onPressed: _resetProgress,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Neue Station'),
        onPressed: () => _openEditor(),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined, color: Colors.amber),
              title: const Text('Item-Bibliothek verwalten'),
              subtitle: Text('${_currentHunt.items.length} Items in dieser Jagd'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _navigateToItemLibrary,
            ),
          ),
          // ============================================================
          // NEU: Karte zur Geofence-Verwaltung
          // ============================================================
           Card(
            margin: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
            child: ListTile(
              leading: const Icon(Icons.location_searching_rounded, color: Colors.cyan),
              title: const Text('Geofence-Trigger verwalten'),
              subtitle: Text('${_currentHunt.geofenceTriggers.length} Trigger in dieser Jagd'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _navigateToGeofenceTriggers,
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.flag_outlined),
                const SizedBox(width: 8),
                Text(
                  'Stationen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: codes.length,
              itemBuilder: (_, i) {
                final code = codes[i];
                final clue = clues[code]!;
                String subtitleText = 'Typ: ${clue.type}';
                if (clue.isRiddle) {
                  subtitleText += ' (Rätsel)';
                }
                return ListTile(
                  title: Text(code),
                  subtitle: Text(subtitleText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_note), onPressed: () => _openEditor(codeToEdit: code)),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _deleteClue(code)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
