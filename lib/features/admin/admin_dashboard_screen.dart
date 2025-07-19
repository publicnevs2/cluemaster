import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import 'admin_editor_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ClueService _clueService = ClueService();
  Map<String, Clue> _clues = {};

  @override
  void initState() {
    super.initState();
    _loadClues();
  }

  Future<void> _loadClues() async {
    final loaded = await _clueService.loadClues();
    setState(() => _clues = loaded);
  }

  Future<void> _deleteClue(String code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: Text('Hinweis "$code" wirklich löschen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (confirm == true) {
      _clues.remove(code);
      await _clueService.saveClues(_clues);
      await _loadClues(); // 🔄 update
    }
  }

  Future<void> _openEditor({String? codeToEdit}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminEditorScreen(
          codeToEdit: codeToEdit,
          existingClue: codeToEdit != null ? _clues[codeToEdit] : null,
          onSave: (Map<String, Clue> updatedMap) async {
            final merged = Map<String, Clue>.from(_clues)..addAll(updatedMap);
            await _clueService.saveClues(merged);
            await _loadClues();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final codes = _clues.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _openEditor(),
      ),
      body: ListView.builder(
        itemCount: codes.length,
        itemBuilder: (_, i) {
          final code = codes[i];
          final clue = _clues[code]!;
          return ListTile(
            title: Text(code),
            subtitle: Text(clue.type),
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
