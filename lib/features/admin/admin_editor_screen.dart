import 'dart:io';

import 'package:clue_master/features/shared/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

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

  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  final _imagePicker = ImagePicker();

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
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _scanQrCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _codeController.text = result;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _saveMediaFile(image.path, image.name);
    }
  }

  Future<void> _pickVideo() async {
    final video = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      await _saveMediaFile(video.path, video.name);
    }
  }

  Future<void> _pickFromCamera() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _saveMediaFile(image.path, image.name);
    }
  }

  Future<void> _toggleRecording() async {
    final isRecording = await _audioRecorder.isRecording();
    if (isRecording) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        await _saveMediaFile(path, 'audio.m4a');
      }
      setState(() => _isRecording = false);
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        await _audioRecorder.start(const RecordConfig(), path: '${dir.path}/temp_audio');
        setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _saveMediaFile(String originalPath, String originalName) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$originalName';
    final newPath = '${dir.path}/$fileName';
    await File(originalPath).copy(newPath);
    setState(() {
      _contentController.text = 'file://$newPath';
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.codeToEdit != null ? 'Bearbeiten' : 'Neuer Hinweis'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Code erforderlich';
                if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) return 'Nur Buchstaben und Zahlen erlaubt';
                return null;
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                UpperCaseTextFormatter(),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Code per QR-Scan setzen'),
              onPressed: _scanQrCode,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'text', child: Text('Text')),
                DropdownMenuItem(value: 'image', child: Text('Bild')),
                DropdownMenuItem(value: 'audio', child: Text('Audio')),
                DropdownMenuItem(value: 'video', child: Text('Video')),
              ],
              onChanged: (value) {
                setState(() {
                  _type = value!;
                  _contentController.clear();
                });
              },
              decoration: const InputDecoration(labelText: 'Typ'),
            ),
            const SizedBox(height: 16),
            if (_type == 'image') ...[
              Row(
                children: [
                  ElevatedButton.icon(onPressed: _pickFromGallery, icon: const Icon(Icons.photo_library), label: const Text('Galerie')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(onPressed: _pickFromCamera, icon: const Icon(Icons.camera_alt), label: const Text('Kamera')),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (_type == 'audio') ...[
              ElevatedButton.icon(
                onPressed: _toggleRecording,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording ? 'Aufnahme stoppen' : 'Audio aufnehmen'),
                style: ElevatedButton.styleFrom(backgroundColor: _isRecording ? Colors.red : null),
              ),
              const SizedBox(height: 16),
            ],
            if (_type == 'video') ...[
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.video_library),
                label: const Text('Video aus Galerie wählen'),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: _type == 'text' ? 'Textinhalt' : 'Pfad zur Datei',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Inhalt erforderlich' : null,
              maxLines: _type == 'text' ? 3 : 1,
              readOnly: _type == 'image' || _type == 'audio' || _type == 'video',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Beschreibung (optional)'),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
