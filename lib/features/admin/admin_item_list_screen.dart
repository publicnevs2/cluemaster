// lib/features/admin/admin_item_list_screen.dart

import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import '../../data/models/item.dart';
import 'admin_item_editor_screen.dart'; // NEU: Import für den Editor

class AdminItemListScreen extends StatefulWidget {
  final Hunt hunt;

  const AdminItemListScreen({super.key, required this.hunt});

  @override
  State<AdminItemListScreen> createState() => _AdminItemListScreenState();
}

class _AdminItemListScreenState extends State<AdminItemListScreen> {
  final ClueService _clueService = ClueService();
  late Map<String, Item> _items;

  @override
  void initState() {
    super.initState();
    _items = Map.from(widget.hunt.items);
  }

  // ============================================================
  // NEU: Logik zum Speichern der Änderungen
  // ============================================================
  Future<void> _saveChanges() async {
    final allHunts = await _clueService.loadHunts();
    final index = allHunts.indexWhere((h) => h.name == widget.hunt.name);
    if (index != -1) {
      allHunts[index].items = _items;
      await _clueService.saveHunts(allHunts);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Änderungen gespeichert.'), duration: Duration(seconds: 1)),
      );
    }
  }

  // ============================================================
  // NEU: Logik zum Öffnen des Editors (für Neu & Bearbeiten)
  // ============================================================
  Future<void> _openItemEditor({Item? existingItem}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminItemEditorScreen(
          existingItem: existingItem,
          existingItemIds: _items.keys.toList(),
          onSave: (newItem) {
            setState(() {
              // Wenn ein Item bearbeitet wird und seine ID sich geändert hat,
              // müssen wir das alte Item zuerst entfernen.
              if (existingItem != null && existingItem.id != newItem.id) {
                _items.remove(existingItem.id);
              }
              _items[newItem.id] = newItem;
            });
            _saveChanges();
          },
        ),
      ),
    );
  }
  
  // ============================================================
  // NEU: Logik zum Löschen eines Items
  // ============================================================
  Future<void> _deleteItem(Item item) async {
     final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: Text('Item "${item.name}" wirklich löschen? Es wird auch aus allen Hinweisen entfernt, die es als Belohnung oder Bedingung nutzen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('LÖSCHEN')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _items.remove(item.id);
      });
      // TODO: Später hier die Logik ergänzen, um die Item-ID aus allen Clues zu entfernen.
      await _saveChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedItems = _items.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: Text('Items für: ${widget.hunt.name}'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Neues Item'),
        onPressed: () => _openItemEditor(), // Ruft jetzt den Editor auf
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'Noch keine Items erstellt.\nTippe auf das "+", um dein erstes Item anzulegen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final item = sortedItems[index];
                return ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, size: 40),
                  title: Text(item.name),
                  subtitle: Text('ID: ${item.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note),
                        tooltip: 'Bearbeiten',
                        onPressed: () => _openItemEditor(existingItem: item), // Ruft Editor auf
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Löschen',
                        onPressed: () => _deleteItem(item), // Ruft Löschen auf
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}