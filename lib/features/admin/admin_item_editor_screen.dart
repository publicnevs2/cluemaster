// lib/features/admin/admin_item_editor_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/item.dart';

class AdminItemEditorScreen extends StatefulWidget {
  final Item? existingItem;
  final List<String> existingItemIds;
  final Function(Item) onSave;

  const AdminItemEditorScreen({
    super.key,
    this.existingItem,
    required this.existingItemIds,
    required this.onSave,
  });

  @override
  State<AdminItemEditorScreen> createState() => _AdminItemEditorScreenState();
}

class _AdminItemEditorScreenState extends State<AdminItemEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _examineTextController;
  late TextEditingController _thumbnailPathController;
  late TextEditingController _contentController;
  
  // TODO: Später durch echte Logik ersetzen
  ItemContentType _selectedContentType = ItemContentType.text;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _idController = TextEditingController(text: item?.id ?? '');
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _examineTextController = TextEditingController(text: item?.examineText ?? '');
    _thumbnailPathController = TextEditingController(text: item?.thumbnailPath ?? '');
    _contentController = TextEditingController(text: item?.content ?? '');
    _selectedContentType = item?.contentType ?? ItemContentType.text;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _examineTextController.dispose();
    _thumbnailPathController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newItem = Item(
        id: _idController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        examineText: _examineTextController.text.trim(),
        // PLATZHALTER - werden später durch echte Dateiauswahl ersetzt
        thumbnailPath: 'assets/items/placeholder.png',
        contentType: _selectedContentType,
        content: _contentController.text.trim(),
      );

      widget.onSave(newItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Item bearbeiten' : 'Neues Item erstellen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Speichern',
            onPressed: _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Eindeutige ID',
                  hintText: 'z.B. schluessel_rot (keine Leerzeichen)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Die ID darf nicht leer sein.';
                  }
                  if (value.contains(' ')) {
                    return 'Die ID darf keine Leerzeichen enthalten.';
                  }
                  // Prüft, ob die ID bereits existiert (außer bei Bearbeitung des eigenen Items)
                  if (!_isEditing && widget.existingItemIds.contains(value.trim())) {
                    return 'Diese ID wird bereits verwendet.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Anzeigename',
                  hintText: 'z.B. Roter Schlüssel',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Der Name darf nicht leer sein.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('Inhalt & Aussehen', style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              const SizedBox(height: 16),
               TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung (Flavor Text)',
                  hintText: 'z.B. Ein alter, rostiger Schlüssel.',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _examineTextController,
                decoration: const InputDecoration(
                  labelText: '"Untersuchen"-Text (optionaler Hinweis)',
                  hintText: 'z.B. Bei genauerer Betrachtung siehst du die Gravur "Keller".',
                ),
                maxLines: 2,
              ),
               const SizedBox(height: 16),
              // PLATZHALTER für Inhaltstyp und Inhalt
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Inhalt (momentan nur Text)',
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}