import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/clue.dart';

class AdminEditorScreen extends StatefulWidget {
  final String? codeToEdit;
  final Clue? existingClue;
  final Function(Map<String, Clue>) onSave;

  const AdminEditorScreen({
    super.key,
    this.codeToEdit,
    this.existingClue,
    required this.onSave,
  });

  @override
  State<AdminEditorScreen> createState() => _AdminEditorScreenState();
}

class _AdminEditorScreenState extends State<AdminEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'text';

  @override
  void initState() {
    super.initState();
    if (widget.existingClue != null) {
      _codeController.text = widget.existingClue!.code;
      _type = widget.existingClue!.type;
      _contentController.text = widget.existingClue!.content;
      _descriptionController.text = widget.existingClue!.description ?? '';
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = image.name;
      final newPath = '${dir.path}/$fileName';
      await File(image.path).copy(newPath);
      setState(() {
        _contentController.text = 'file://$newPath';
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final clue = Clue(
        code: _codeController.text.trim(),
        type: _type,
        content: _contentController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      final updatedMap = Map<String, Clue>.from(widget.existingClue != null
          ? {widget.codeToEdit!: clue}
          : {clue.code: clue});
      widget.onSave(updatedMap);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.codeToEdit != null ? 'Bearbeiten' : 'Neuer Hinweis'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Code-Feld: Nur alphanumerisch + optional Uppercase-Formatter
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Code erforderlich';
                }
                if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
                  return 'Nur Buchstaben und Zahlen erlaubt';
                }
                return null;
              },
              readOnly: widget.codeToEdit != null,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                UpperCaseTextFormatter(),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'text', child: Text('Text')),
                DropdownMenuItem(value: 'image', child: Text('Bild')),
              ],
              onChanged: (value) {
                setState(() => _type = value!);
              },
              decoration: const InputDecoration(labelText: 'Typ'),
            ),
            const SizedBox(height: 16),
            if (_type == 'image') ...[
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Bild wählen'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _contentController.text.isEmpty
                          ? 'Kein Bild ausgewählt'
                          : _contentController.text,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText:
                    _type == 'text' ? 'Textinhalt' : 'Pfad zum Bild',
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Inhalt erforderlich'
                  : null,
              maxLines: _type == 'text' ? 3 : 1,
              readOnly: _type == 'image',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Beschreibung (optional)'),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

/// Wandelt alle eingegebenen Zeichen in Großbuchstaben um
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
