// lib/features/admin/admin_global_item_list_screen.dart

import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/item.dart';
import 'admin_global_item_editor_screen.dart';

class AdminGlobalItemListScreen extends StatefulWidget {
  const AdminGlobalItemListScreen({super.key});

  @override
  State<AdminGlobalItemListScreen> createState() =>
      _AdminGlobalItemListScreenState();
}

class _AdminGlobalItemListScreenState extends State<AdminGlobalItemListScreen> {
  final ClueService _clueService = ClueService();
  List<Item> _globalItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await _clueService.loadGlobalItems();
    if (mounted) {
      setState(() {
        _globalItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _openEditor({Item? existingItem}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminGlobalItemEditorScreen(
          existingItem: existingItem,
          existingItemIds: _globalItems.map((i) => i.id).toList(),
          onSave: (newItem) async {
            setState(() {
              final index =
                  _globalItems.indexWhere((item) => item.id == newItem.id);
              if (index != -1) {
                _globalItems[index] = newItem;
              } else {
                _globalItems.add(newItem);
              }
            });
            await _clueService.saveGlobalItems(_globalItems);
          },
        ),
      ),
    );
  }

  Future<void> _deleteItem(Item item) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Löschen bestätigen'),
              content: Text(
                  'Werkzeug "${item.name}" wirklich löschen? Es wird aus allen Jagden entfernt, die es als Belohnung nutzen.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Abbrechen')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('LÖSCHEN')),
              ],
            ));

    if (confirm == true) {
      setState(() {
        _globalItems.removeWhere((i) => i.id == item.id);
      });
      await _clueService.saveGlobalItems(_globalItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Globale Werkzeugkiste'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Neues Werkzeug'),
        onPressed: () => _openEditor(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _globalItems.isEmpty
              ? const Center(
                  child: Text(
                    'Noch keine globalen Werkzeuge oder Info-Items erstellt.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: _globalItems.length,
                  itemBuilder: (context, index) {
                    final item = _globalItems[index];
                    return ListTile(
                      leading: Icon(
                          item.itemCategory == ItemCategory.INTERACTIVE
                              ? Icons.construction
                              : Icons.info_outline,
                          size: 40),
                      title: Text(item.name),
                      subtitle: Text('ID: ${item.id}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_note),
                            onPressed: () => _openEditor(existingItem: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            onPressed: () => _deleteItem(item),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
