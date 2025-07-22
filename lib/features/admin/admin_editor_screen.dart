// ============================================================
// SECTION: Imports
// ============================================================
import 'dart:io';
import 'package:clue_master/features/shared/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../data/models/clue.dart';

// ============================================================
// SECTION: AdminEditorScreen Widget
// ============================================================
class AdminEditorScreen extends StatefulWidget {
  final String? codeToEdit;
  final Clue? existingClue;
  final Function(Map<String, Clue>) onSave;
  // NEU: Nimmt die Liste der existierenden Codes entgegen.
  final List<String> existingCodes;

  const AdminEditorScreen({
    super.key,
    this.codeToEdit,
    this.existingClue,
    required this.onSave,
    this.existingCodes = const [], // Standardwert ist eine leere Liste.
  });

  @override
  State<AdminEditorScreen> createState() => _AdminEditorScreenState();
}

// ============================================================
// SECTION: State-Klasse
// ============================================================
class _AdminEditorScreenState extends State<AdminEditorScreen> {
  // ... (alle Controller und initState/dispose bleiben unverändert)
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  final _codeController = TextEditingController();
  String _type = 'text';
  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isRiddle = false;
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _hint1Controller = TextEditingController();
  final _hint2Controller = TextEditingController();
  final _rewardTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingClue != null) {
      final clue = widget.existingClue!;
      _codeController.text = clue.code;
      _type = clue.type;
      _contentController.text = clue.content;
      _descriptionController.text = clue.description ?? '';
      if (clue.isRiddle) {
        _isRiddle = true;
        _questionController.text = clue.question!;
        _answerController.text = clue.answer!;
        _hint1Controller.text = clue.hint1 ?? '';
        _hint2Controller.text = clue.hint2 ?? '';
        _rewardTextController.text = clue.rewardText ?? '';
        if (clue.isMultipleChoice) {
          _option1Controller.text = clue.options![0];
          _option2Controller.text = clue.options!.length > 1 ? clue.options![1] : '';
          _option3Controller.text = clue.options!.length > 2 ? clue.options![2] : '';
          _option4Controller.text = clue.options!.length > 3 ? clue.options![3] : '';
        }
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _hint1Controller.dispose();
    _hint2Controller.dispose();
    _rewardTextController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // ============================================================
  // SECTION: Logik
  // ============================================================
  void _save() {
    if (_formKey.currentState!.validate()) {
      final options = [
        _option1Controller.text.trim(),
        _option2Controller.text.trim(),
        _option3Controller.text.trim(),
        _option4Controller.text.trim(),
      ].where((o) => o.isNotEmpty).toList();

      final clue = Clue(
        code: _codeController.text.trim(),
        type: _type,
        content: _contentController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        question: _isRiddle ? _questionController.text.trim() : null,
        answer: _isRiddle ? _answerController.text.trim() : null,
        options: _isRiddle && options.isNotEmpty ? options : null,
        hint1: _isRiddle && _hint1Controller.text.trim().isNotEmpty ? _hint1Controller.text.trim() : null,
        hint2: _isRiddle && _hint2Controller.text.trim().isNotEmpty ? _hint2Controller.text.trim() : null,
        rewardText: _isRiddle && _rewardTextController.text.trim().isNotEmpty ? _rewardTextController.text.trim() : null,
      );

      final updatedMap = {clue.code: clue};
      widget.onSave(updatedMap);
      Navigator.pop(context);
    }
  }

  Future<void> _pickMedia(ImageSource source) async {
    XFile? mediaFile;
    if (_type == 'image') {
      mediaFile = await _imagePicker.pickImage(source: source);
    } else if (_type == 'video') {
      mediaFile = await _imagePicker.pickVideo(source: source);
    }
    
    if (mediaFile != null) {
      await _saveMediaFile(mediaFile.path, mediaFile.name, _contentController);
    }
  }

  Future<void> _toggleRecording() async {
    if (await _audioRecorder.isRecording()) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        await _saveMediaFile(path, 'audio_aufnahme.m4a', _contentController);
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

  Future<void> _saveMediaFile(String originalPath, String originalName, TextEditingController controller) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$originalName';
    final newPath = '${dir.path}/$fileName';
    await File(originalPath).copy(newPath);
    setState(() {
      controller.text = 'file://$newPath';
    });
  }
  
  // ============================================================
  // SECTION: UI-Aufbau (build-Methode)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.codeToEdit != null ? 'Station bearbeiten' : 'Neue Station'),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.save))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- HINWEIS-SEKTION ---
            _buildSectionHeader('Hinweis (wird immer angezeigt)'),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code der Station'),
              // KORREKTUR: Validierung für Pflichtfeld und Duplikate
              validator: (value) {
                final code = value?.trim() ?? '';
                if (code.isEmpty) {
                  return 'Der Code ist ein Pflichtfeld.';
                }
                // Prüfe auf Duplikate, aber nur, wenn es ein neuer Code ist.
                // Wenn wir einen Code bearbeiten, darf er sich selbst natürlich finden.
                if (widget.codeToEdit == null && widget.existingCodes.contains(code)) {
                  return 'Dieser Code existiert bereits in dieser Jagd.';
                }
                // Wenn wir einen Code umbenennen, prüfen wir, ob der neue Name schon existiert.
                if (widget.codeToEdit != null && code != widget.codeToEdit && widget.existingCodes.contains(code)) {
                  return 'Dieser Code existiert bereits in dieser Jagd.';
                }
                return null;
              },
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
              onChanged: (value) => setState(() {
                _type = value!;
                _contentController.clear();
              }),
              decoration: const InputDecoration(labelText: 'Typ des Hinweises'),
            ),
            const SizedBox(height: 8),
            _buildMediaContentField(),
            
            // --- RÄTSEL-SEKTION ---
            const Divider(height: 40, thickness: 1),
            CheckboxListTile(
              title: const Text('Optionales Rätsel hinzufügen'),
              subtitle: const Text('Wenn aktiviert, muss der Spieler erst eine Frage beantworten.'),
              value: _isRiddle,
              onChanged: (value) => setState(() => _isRiddle = value ?? false),
            ),
            if (_isRiddle) ...[
              _buildSectionHeader('Rätsel-Details'),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Frage zum Hinweis'),
                validator: (v) => (_isRiddle && (v == null || v.isEmpty)) ? 'Frage erforderlich' : null,
              ),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Korrekte Antwort'),
                validator: (v) => (_isRiddle && (v == null || v.isEmpty)) ? 'Antwort erforderlich' : null,
              ),
              const SizedBox(height: 16),
              _buildMultipleChoiceFields(),
              const SizedBox(height: 16),
              _buildSectionHeader('Gestaffelte Hilfe (Optional)'),
              TextFormField(controller: _hint1Controller, decoration: const InputDecoration(labelText: 'Hilfe nach 3 Fehlversuchen')),
              TextFormField(controller: _hint2Controller, decoration: const InputDecoration(labelText: 'Hilfe nach 6 Fehlversuchen')),
              const SizedBox(height: 16),
              _buildSectionHeader('Belohnung nach gelöstem Rätsel'),
              TextFormField(
                controller: _rewardTextController,
                decoration: const InputDecoration(labelText: 'Belohnungs-Text', hintText: 'z.B. Gut gemacht! Der nächste Code ist...'),
                maxLines: 3,
                validator: (v) => (_isRiddle && (v == null || v.isEmpty)) ? 'Belohnungstext erforderlich' : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ... (Restliche UI-Hilfsmethoden bleiben unverändert)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildMediaContentField() {
    if (_type == 'text') {
      return Column(children: [
        TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(labelText: 'Hinweis-Text'),
          maxLines: 3,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Inhalt erforderlich' : null,
        ),
        TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Beschreibung (optional)')),
      ]);
    } else {
      return Column(children: [
        TextFormField(
          controller: _contentController,
          readOnly: true,
          decoration: InputDecoration(labelText: 'Dateipfad (${_type.capitalize()})'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Datei erforderlich' : null,
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          if (_type == 'image' || _type == 'video') ...[
            ElevatedButton.icon(icon: const Icon(Icons.photo_library), label: const Text('Galerie'), onPressed: () => _pickMedia(ImageSource.gallery)),
            ElevatedButton.icon(icon: const Icon(Icons.camera_alt), label: const Text('Kamera'), onPressed: () => _pickMedia(ImageSource.camera)),
          ],
          if (_type == 'audio')
            ElevatedButton.icon(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Stopp' : 'Aufnehmen'),
              onPressed: _toggleRecording,
              style: ElevatedButton.styleFrom(backgroundColor: _isRecording ? Colors.red : null),
            ),
        ]),
        TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Beschreibung (optional)')),
      ]);
    }
  }

  Widget _buildMultipleChoiceFields() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      const Text('Multiple-Choice Optionen (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
      TextFormField(controller: _option1Controller, decoration: const InputDecoration(labelText: 'Option 1')),
      TextFormField(controller: _option2Controller, decoration: const InputDecoration(labelText: 'Option 2')),
      TextFormField(controller: _option3Controller, decoration: const InputDecoration(labelText: 'Option 3')),
      TextFormField(controller: _option4Controller, decoration: const InputDecoration(labelText: 'Option 4')),
    ]);
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${this.substring(1)}";
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
