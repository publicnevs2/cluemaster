// lib/features/admin/admin_item_editor_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
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

  // =======================================================
  // NEU: Controller und State-Variablen für Medien
  // =======================================================
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _examineTextController;
  late TextEditingController _contentController;
  late ItemContentType _selectedContentType;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _idController = TextEditingController(text: item?.id ?? '');
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _examineTextController = TextEditingController(text: item?.examineText ?? '');
    _contentController = TextEditingController(text: item?.content ?? '');
    _selectedContentType = item?.contentType ?? ItemContentType.text;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _examineTextController.dispose();
    _contentController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // =======================================================
  // NEU: Methoden zum Auswählen und Speichern von Medien
  // =======================================================
  Future<void> _pickMedia(ImageSource source) async {
    XFile? mediaFile;
    if (_selectedContentType == ItemContentType.image) {
      mediaFile = await _imagePicker.pickImage(source: source, imageQuality: 80);
    } else if (_selectedContentType == ItemContentType.video) {
      mediaFile = await _imagePicker.pickVideo(source: source);
    }
    if (mediaFile != null) {
      await _saveMediaFile(mediaFile.path, mediaFile.name);
    }
  }

  Future<void> _toggleRecording() async {
    if (await _audioRecorder.isRecording()) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        await _saveMediaFile(path, 'audio_aufnahme.m4a');
      }
      if (mounted) setState(() => _isRecording = false);
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        await _audioRecorder.start(const RecordConfig(),
            path: '${dir.path}/temp_audio');
        if (mounted) setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _saveMediaFile(String originalPath, String originalName) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$originalName';
    final newPath = '${dir.path}/$fileName';
    await File(originalPath).copy(newPath);
    if (mounted) {
      setState(() {
        _contentController.text = 'file://$newPath';
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newItem = Item(
        id: _idController.text.trim(),
        name: _nameController.text.trim(),
        thumbnailPath: 'assets/items/placeholder.png', // Platzhalter
        contentType: _selectedContentType,
        content: _contentController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        examineText: _examineTextController.text.trim().isEmpty
            ? null
            : _examineTextController.text.trim(),
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
              Text('Inhalt & Aussehen',
                  style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              const SizedBox(height: 16),
              DropdownButtonFormField<ItemContentType>(
                value: _selectedContentType,
                items: const [
                  DropdownMenuItem(value: ItemContentType.text, child: Text('Text')),
                  DropdownMenuItem(value: ItemContentType.image, child: Text('Bild')),
                  DropdownMenuItem(value: ItemContentType.audio, child: Text('Audio')),
                  DropdownMenuItem(value: ItemContentType.video, child: Text('Video')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedContentType = value;
                      _contentController.clear();
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Typ des Inhalts'),
              ),
              const SizedBox(height: 16),
              _buildMediaContentField(),
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
                  hintText:
                      'z.B. Bei genauerer Betrachtung siehst du die Gravur "Keller".',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContentField() {
    switch (_selectedContentType) {
      case ItemContentType.text:
        return TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(labelText: 'Inhalt (Text)'),
          maxLines: 4,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Inhalt erforderlich' : null,
        );
      case ItemContentType.image:
      case ItemContentType.video:
        return Column(
          children: [
            TextFormField(
              controller: _contentController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Dateipfad (${_selectedContentType.name})'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Datei erforderlich' : null,
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerie'),
                  onPressed: () => _pickMedia(ImageSource.gallery)),
              ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                  onPressed: () => _pickMedia(ImageSource.camera)),
            ]),
          ],
        );
      case ItemContentType.audio:
        return Column(
          children: [
            TextFormField(
              controller: _contentController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Dateipfad (audio)'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Datei erforderlich' : null,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Stopp' : 'Aufnehmen'),
              onPressed: _toggleRecording,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : null),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
