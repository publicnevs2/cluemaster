// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import 'admin_editor_screen.dart';

// ============================================================
// SECTION: AdminDashboardScreen Widget
// ============================================================
class AdminDashboardScreen extends StatefulWidget {
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
  late Map<String, Clue> _clues;

  // ============================================================
  // SECTION: Lifecycle
  // ============================================================
  @override
  void initState() {
    super.initState();
    _clues = widget.hunt.clues;
  }

  // ============================================================
  // SECTION: Helper-Methoden
  // ============================================================
  Future<void> _saveChanges() async {
    final allHunts = await _clueService.loadHunts();
    final index = allHunts.indexWhere((h) => h.name == widget.hunt.name);
    if (index != -1) {
      allHunts[index].clues = _clues;
      await _clueService.saveHunts(allHunts);
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
      setState(() {
        _clues.remove(code);
      });
      await _saveChanges();
    }
  }

  Future<void> _openEditor({String? codeToEdit}) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AdminEditorScreen(
            codeToEdit: codeToEdit,
            existingClue: codeToEdit != null ? _clues[codeToEdit] : null,
            existingCodes: _clues.keys.toList(),
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
        title: Text('Stationen: ${widget.hunt.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Alle als offen markieren',
            onPressed: _resetSolvedFlags,
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
