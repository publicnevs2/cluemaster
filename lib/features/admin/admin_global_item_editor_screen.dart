// lib/features/admin/admin_global_item_editor_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/item.dart';

class AdminGlobalItemEditorScreen extends StatefulWidget {
  final Item? existingItem;
  final List<String> existingItemIds;
  final Function(Item) onSave;

  const AdminGlobalItemEditorScreen({
    super.key,
    this.existingItem,
    required this.existingItemIds,
    required this.onSave,
  });

  @override
  State<AdminGlobalItemEditorScreen> createState() =>
      _AdminGlobalItemEditorScreenState();
}

class _AdminGlobalItemEditorScreenState
    extends State<AdminGlobalItemEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _contentController;
  late ItemCategory _selectedCategory;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _idController = TextEditingController(text: item?.id ?? '');
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController =
        TextEditingController(text: item?.description ?? '');
    _contentController = TextEditingController(text: item?.content ?? '');
    _selectedCategory = item?.itemCategory ?? ItemCategory.INFO;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newItem = Item(
        id: _idController.text.trim(),
        name: _nameController.text.trim(),
        thumbnailPath: 'assets/items/placeholder.png', // Platzhalter
        contentType: _selectedCategory == ItemCategory.INTERACTIVE
            ? ItemContentType.interactive_widget
            : ItemContentType.text,
        content: _contentController.text.trim(),
        description: _descriptionController.text.trim(),
        itemCategory: _selectedCategory,
      );

      widget.onSave(newItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Werkzeug bearbeiten' : 'Neues Werkzeug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
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
                  hintText: 'z.B. morse_alphabet (keine Leerzeichen)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Die ID darf nicht leer sein.';
                  }
                  if (value.contains(' ')) {
                    return 'Die ID darf keine Leerzeichen enthalten.';
                  }
                  if (!_isEditing &&
                      widget.existingItemIds.contains(value.trim())) {
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
                  hintText: 'z.B. Morse-Alphabet',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Der Name darf nicht leer sein.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ItemCategory>(
                value: _selectedCategory,
                items: const [
                  DropdownMenuItem(
                      value: ItemCategory.INFO,
                      child: Text('Info-Item (Nachschlagewerk)')),
                  DropdownMenuItem(
                      value: ItemCategory.INTERACTIVE,
                      child: Text('Interaktives Werkzeug')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Typ des Werkzeugs'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: _selectedCategory == ItemCategory.INTERACTIVE
                      ? 'Widget-Kennung'
                      : 'Inhalt (Text)',
                  hintText: _selectedCategory == ItemCategory.INTERACTIVE
                      ? 'z.B. taschenlampe'
                      : 'Hier den Text für das Nachschlagewerk eingeben.',
                ),
                maxLines: _selectedCategory == ItemCategory.INTERACTIVE ? 1 : 5,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Dieses Feld ist Pflicht.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  hintText: 'z.B. Ein Standard-Alphabet zur Morsetelegrafie.',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
