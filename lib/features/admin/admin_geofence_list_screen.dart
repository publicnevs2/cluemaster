// lib/features/admin/admin_geofence_list_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import 'admin_geofence_editor_screen.dart';

class AdminGeofenceListScreen extends StatefulWidget {
  final Hunt hunt;

  const AdminGeofenceListScreen({super.key, required this.hunt});

  @override
  State<AdminGeofenceListScreen> createState() =>
      _AdminGeofenceListScreenState();
}

class _AdminGeofenceListScreenState extends State<AdminGeofenceListScreen> {
  final ClueService _clueService = ClueService();
  late List<GeofenceTrigger> _triggers;

  @override
  void initState() {
    super.initState();
    _triggers = List.from(widget.hunt.geofenceTriggers);
  }

  Future<void> _saveChanges() async {
    final allHunts = await _clueService.loadHunts();
    final index = allHunts.indexWhere((h) => h.name == widget.hunt.name);
    if (index != -1) {
      // Erstelle eine neue Hunt-Instanz mit der aktualisierten Trigger-Liste
      final updatedHunt = Hunt(
        name: allHunts[index].name,
        clues: allHunts[index].clues,
        items: allHunts[index].items,
        briefingText: allHunts[index].briefingText,
        briefingImageUrl: allHunts[index].briefingImageUrl,
        startingItemIds: allHunts[index].startingItemIds,
        targetTimeInMinutes: allHunts[index].targetTimeInMinutes,
        geofenceTriggers: _triggers,
      );
      allHunts[index] = updatedHunt;
      await _clueService.saveHunts(allHunts);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Änderungen gespeichert.'),
            duration: Duration(seconds: 1)),
      );
    }
  }

  Future<void> _openEditor({GeofenceTrigger? existingTrigger}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminGeofenceEditorScreen(
          existingTrigger: existingTrigger,
          hunt: widget.hunt,
          existingTriggerIds: _triggers.map((t) => t.id).toList(),
          onSave: (newTrigger) {
            setState(() {
              final index =
                  _triggers.indexWhere((t) => t.id == newTrigger.id);
              if (index != -1) {
                _triggers[index] = newTrigger;
              } else {
                _triggers.add(newTrigger);
              }
            });
            _saveChanges();
          },
        ),
      ),
    );
  }

  Future<void> _deleteTrigger(GeofenceTrigger trigger) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: Text(
            'Trigger "${trigger.id}" wirklich löschen?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('LÖSCHEN')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _triggers.removeWhere((t) => t.id == trigger.id);
      });
      await _saveChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence-Trigger'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Neuer Trigger'),
        onPressed: () => _openEditor(),
      ),
      body: _triggers.isEmpty
          ? const Center(
              child: Text(
                'Noch keine Trigger erstellt.\nEin Trigger löst automatisch eine Nachricht aus, wenn der Spieler einen bestimmten Ort betritt.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _triggers.length,
              itemBuilder: (context, index) {
                final trigger = _triggers[index];
                return ListTile(
                  leading: const Icon(Icons.location_searching, size: 40),
                  title: Text('ID: ${trigger.id}'),
                  subtitle: Text(trigger.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note),
                        tooltip: 'Bearbeiten',
                        onPressed: () => _openEditor(existingTrigger: trigger),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        tooltip: 'Löschen',
                        onPressed: () => _deleteTrigger(trigger),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
