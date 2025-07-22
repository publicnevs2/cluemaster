// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import 'admin_dashboard_screen.dart';
import 'admin_change_password_screen.dart';

// ============================================================
// SECTION: AdminHuntListScreen Widget
// ============================================================
class AdminHuntListScreen extends StatefulWidget {
  const AdminHuntListScreen({super.key});

  @override
  State<AdminHuntListScreen> createState() => _AdminHuntListScreenState();
}

// ============================================================
// SECTION: State-Klasse
// ============================================================
class _AdminHuntListScreenState extends State<AdminHuntListScreen> {
  // ============================================================
  // SECTION: State & Controller
  // ============================================================
  final ClueService _clueService = ClueService();
  List<Hunt> _hunts = [];

  // ============================================================
  // SECTION: Lifecycle
  // ============================================================
  @override
  void initState() {
    super.initState();
    _loadHunts();
  }

  // ============================================================
  // SECTION: Logik
  // ============================================================

  /// Lädt alle Schnitzeljagden aus der Datei.
  Future<void> _loadHunts() async {
    final loadedHunts = await _clueService.loadHunts();
    if (mounted) {
      setState(() => _hunts = loadedHunts);
    }
  }

  /// Öffnet einen Dialog, um eine neue Schnitzeljagd zu erstellen.
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
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
      if (_hunts.any((hunt) => hunt.name.toLowerCase() == newHuntName.toLowerCase())) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eine Jagd mit diesem Namen existiert bereits.'), backgroundColor: Colors.red),
        );
        return;
      }

      final newHunt = Hunt(name: newHuntName, clues: {});
      _hunts.add(newHunt);
      await _clueService.saveHunts(_hunts);
      _loadHunts();
    }
  }

  /// Navigiert zum Dashboard, um die Hinweise einer bestimmten Jagd zu bearbeiten.
  void _editHunt(Hunt hunt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // KORREKTUR: Wir übergeben die ausgewählte 'hunt' an den AdminDashboardScreen.
        builder: (_) => AdminDashboardScreen(hunt: hunt),
      ),
    ).then((_) => _loadHunts()); // Lade die Jagden neu, wenn wir vom Bearbeiten zurückkehren.
  }

  /// Löscht eine Schnitzeljagd nach Bestätigung.
  Future<void> _deleteHunt(Hunt huntToDelete) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Jagd löschen?'),
              content: Text('Möchtest du die Schnitzeljagd "${huntToDelete.name}" wirklich endgültig löschen?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
              ],
            ));

    if (confirm == true) {
      _hunts.removeWhere((hunt) => hunt.name == huntToDelete.name);
      await _clueService.saveHunts(_hunts);
      _loadHunts();
    }
  }

  // ============================================================
  // SECTION: UI-Aufbau
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Schnitzeljagden'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Passwort ändern',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminChangePasswordScreen()),
              );
            },
          ),
        ],
      ),
      body: _hunts.isEmpty
          ? const Center(
              child: Text('Keine Schnitzeljagden gefunden. Erstelle eine neue!'),
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
