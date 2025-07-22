// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart'; // NEU: Import für das Hunt-Modell
import 'admin_editor_screen.dart';
import 'admin_change_password_screen.dart';

// ============================================================
// SECTION: AdminDashboardScreen Widget
// ============================================================
class AdminDashboardScreen extends StatefulWidget {
  // NEU: Der Screen benötigt jetzt eine 'Hunt', um zu wissen, was er anzeigen soll.
  final Hunt hunt;

  const AdminDashboardScreen({super.key, required this.hunt});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

// ============================================================
// SECTION: State-Klasse
// ============================================================
class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ClueService _clueService = ClueService();
  
  // Die Hinweise werden nicht mehr aus der Datei geladen, sondern direkt von der übergebenen Jagd genommen.
  late Map<String, Clue> _clues;

  // ============================================================
  // SECTION: Lifecycle
  // ============================================================
  @override
  void initState() {
    super.initState();
    // Initialisiere die lokale Clue-Map mit den Daten aus dem Widget.
    _clues = widget.hunt.clues;
  }

  // ============================================================
  // SECTION: Helper-Methoden
  // ============================================================

  /// Speichert die komplette Liste aller Schnitzeljagden, nachdem eine Änderung vorgenommen wurde.
  Future<void> _saveChanges() async {
    // 1. Lade die aktuelle Liste aller Jagden.
    final allHunts = await _clueService.loadHunts();
    
    // 2. Finde den Index der Jagd, die wir gerade bearbeiten.
    final index = allHunts.indexWhere((h) => h.name == widget.hunt.name);

    // 3. Aktualisiere die Clues in dieser Jagd und speichere die gesamte Liste.
    if (index != -1) {
      allHunts[index].clues = _clues;
      await _clueService.saveHunts(allHunts);
    }
  }

  /// Löscht einen einzelnen Clue nach Bestätigung.
  Future<void> _deleteClue(String code) async {
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
      setState(() {
        _clues.remove(code);
      });
      await _saveChanges();
    }
  }

  /// Öffnet den Editor zum Bearbeiten oder Hinzufügen eines Clues.
  Future<void> _openEditor({String? codeToEdit}) async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AdminEditorScreen(
            codeToEdit: codeToEdit,
            existingClue: codeToEdit != null ? _clues[codeToEdit] : null,
            onSave: (updatedMap) async {
              setState(() {
                if (codeToEdit != null && updatedMap.keys.first != codeToEdit) {
                  _clues.remove(codeToEdit);
                }
                _clues.addAll(updatedMap);
              });
              await _saveChanges();
            },
          );
        },
      ),
    );
  }

  /// Setzt alle 'solved' Flags in den Clues auf false zurück.
  Future<void> _resetSolvedFlags() async {
    setState(() {
      for (var clue in _clues.values) {
        clue.solved = false;
      }
    });
    await _saveChanges();
  }

  // ============================================================
  // SECTION: Build-Method (UI-Aufbau)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final codes = _clues.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        // Der Titel zeigt jetzt den Namen der aktuellen Schnitzeljagd an.
        title: Text('Stationen: ${widget.hunt.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Alle als offen markieren',
            onPressed: () async {
              // ... (Dialog-Logik bleibt gleich)
              _resetSolvedFlags();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _openEditor(),
      ),
      body: ListView.builder(
        itemCount: codes.length,
        itemBuilder: (_, i) {
          final code = codes[i];
          final clue = _clues[code]!;

          // KORREKTUR: Die Felder wurden an das neue Datenmodell angepasst.
          String subtitleText = 'Typ: ${clue.type}';
          if (clue.isRiddle) {
            subtitleText += ' (Rätsel)';
          }
          if (clue.solved) {
            subtitleText += ' - Gefunden';
          }

          return ListTile(
            title: Text(code),
            subtitle: Text(subtitleText),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _openEditor(codeToEdit: code)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteClue(code)),
              ],
            ),
          );
        },
      ),
    );
  }
}
