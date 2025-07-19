// ============================================================
// Datei: lib/features/admin/admin_editor_screen.dart
// ============================================================

// ============================================================
// SECTION: Imports
// ============================================================
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/clue.dart';

// ============================================================
// SECTION: AdminEditorScreen Widget
// ============================================================
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

// ============================================================
// SECTION: State & Controller
// ============================================================
class _AdminEditorScreenState extends State<AdminEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'text';

// ============================================================
// SECTION: Lifecycle
// ============================================================
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

  @override
  void dispose() {
    _codeController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

// ============================================================
// SECTION: Helper-Methoden
// ============================================================

  /// Wählt ein Bild aus der Galerie und kopiert es in App-Verzeichnis
  Future<void> _pickFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _saveImageFile(image);
    }
  }

  /// Nimmt ein Foto mit der Kamera auf und kopiert es in App-Verzeichnis
  Future<void> _pickFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      await _saveImageFile(image);
    }
  }

  /// Gemeinsame Logik: Bild-Datei kopieren und Pfad ins Content-Feld schreiben
  Future<void> _saveImageFile(XFile image) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '_' + image.name;
    final newPath = '${dir.path}/$fileName';
    await File(image.path).copy(newPath);
    setState(() {
      _contentController.text = 'file://$newPath';
    });
  }

  /// Speichert neuen oder bearbeiteten Clue
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

// ============================================================
// SECTION: Build-Method (UI-Aufbau)
// ============================================================
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
            // Code-Feld
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

            // Typ-Auswahl
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

            // Bild-Optionen: Galerie oder Kamera
            if (_type == 'image') ...[
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galerie'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Content-Feld (Text oder Pfad)
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText:
                    _type == 'text' ? 'Textinhalt' : 'Pfad zum Bild',
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Inhalt erforderlich' : null,
              maxLines: _type == 'text' ? 3 : 1,
              readOnly: _type == 'image',
            ),
            const SizedBox(height: 16),

            // Beschreibung (optional)
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

/// ============================================================
/// SECTION: Text Formatter
/// Wandelt alle Zeichen in Großbuchstaben um
/// ============================================================
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
