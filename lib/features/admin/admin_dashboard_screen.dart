// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import 'admin_editor_screen.dart';
import 'admin_change_password_screen.dart';

// ============================================================
// SECTION: AdminDashboardScreen Widget
// ============================================================
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

// ============================================================
// SECTION: State & Controller
// ============================================================
class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ClueService _clueService = ClueService();
  Map<String, Clue> _clues = {};

  // ============================================================
  // SECTION: Lifecycle
  // ============================================================
  @override
  void initState() {
    super.initState();
    _loadClues();
  }

  // ============================================================
  // SECTION: Helper-Methoden
  // ============================================================

  /// Lädt alle Clues neu aus der JSON-Datei.
  Future<void> _loadClues() async {
    final loaded = await _clueService.loadClues();
    if (mounted) {
      setState(() => _clues = loaded);
    }
  }

  /// Löscht einen einzelnen Clue nach Bestätigung.
  Future<void> _deleteClue(String code) async {
    if (!mounted) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: Text('Station "$code" wirklich löschen?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Löschen')),
        ],
      ),
    );
    if (confirm == true) {
      _clues.remove(code);
      await _clueService.saveClues(_clues);
      await _loadClues();
    }
  }

  /// Öffnet den Editor zum Bearbeiten oder Hinzufügen eines Clues.
  Future<void> _openEditor({String? codeToEdit}) async {
    if (!mounted) return;

    final onSaveCallback = (Map<String, Clue> updatedMap) async {
      final merged = Map<String, Clue>.from(_clues)..addAll(updatedMap);
      if (codeToEdit != null && updatedMap.keys.first != codeToEdit) {
        merged.remove(codeToEdit);
      }
      await _clueService.saveClues(merged);
      await _loadClues();
    };

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AdminEditorScreen(
            codeToEdit: codeToEdit,
            existingClue: codeToEdit != null ? _clues[codeToEdit] : null,
            onSave: onSaveCallback,
          );
        },
      ),
    );
  }

  /// Setzt alle 'solved' Flags in den Clues auf false zurück.
  Future<void> _resetSolvedFlags() async {
    final resetMap = _clues.map((code, clue) {
      clue.solved = false;
      return MapEntry(code, clue);
    });
    await _clueService.saveClues(resetMap);
    await _loadClues();
  }

  // ============================================================
  // SECTION: Build-Method (UI-Aufbau)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final codes = _clues.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Passwort ändern',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminChangePasswordScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Alle als offen markieren',
            onPressed: () async {
              if (!mounted) return;
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Zurücksetzen'),
                  content: const Text('Alle Stationen als ungelöst markieren?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Abbrechen')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('OK')),
                  ],
                ),
              );
              if (ok == true) await _resetSolvedFlags();
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

          // KORREKTUR: Der Untertitel wurde an das neue Datenmodell angepasst.
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
                IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openEditor(codeToEdit: code)),
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteClue(code)),
              ],
            ),
          );
        },
      ),
    );
  }
}
