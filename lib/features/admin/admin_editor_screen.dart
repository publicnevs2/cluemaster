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
// SECTION: State-Klasse
// ============================================================
class _AdminEditorScreenState extends State<AdminEditorScreen> {
  // ============================================================
  // SECTION: State & Controller
  // ============================================================
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'text';

  // Controller und Status für Rätsel
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  bool _isRiddle = false;

  // Controller für Multiple-Choice-Optionen
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();

  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  final _imagePicker = ImagePicker();

  // ============================================================
  // SECTION: Lifecycle-Methoden
  // ============================================================
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
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        question: _isRiddle ? _questionController.text.trim() : null,
        answer: _isRiddle ? _answerController.text.trim() : null,
        options: _isRiddle && options.isNotEmpty ? options : null,
      );

      final updatedMap = {clue.code: clue};
      widget.onSave(updatedMap);
      Navigator.pop(context);
    }
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

  // ============================================================
  // SECTION: UI-Aufbau (build-Methode)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.codeToEdit != null ? 'Hinweis bearbeiten' : 'Neuer Hinweis'),
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
              decoration: const InputDecoration(labelText: 'Typ des Hinweises/Rätsels'),
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
                labelText: _type == 'text' ? 'Textinhalt des Hinweises' : 'Pfad zur Datei',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Inhalt erforderlich' : null,
              maxLines: _type == 'text' ? 3 : 1,
              readOnly: _type != 'text',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Beschreibung (optional)'),
              maxLines: 2,
            ),
            
            const Divider(height: 40, thickness: 1),
            CheckboxListTile(
              title: const Text('Rätsel zu diesem Hinweis hinzufügen'),
              value: _isRiddle,
              onChanged: (value) {
                setState(() {
                  _isRiddle = value ?? false;
                });
              },
            ),
            if (_isRiddle) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Frage zum Hinweis',
                  hintText: 'z.B. Wie viele Vögel siehst du?',
                ),
                validator: (value) => (_isRiddle && (value == null || value.isEmpty)) ? 'Frage erforderlich' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: 'Korrekte Antwort',
                  hintText: 'z.B. 3 (Groß-/Kleinschreibung wird ignoriert)',
                ),
                validator: (value) => (_isRiddle && (value == null || value.isEmpty)) ? 'Antwort erforderlich' : null,
              ),

              const SizedBox(height: 24),
              const Text('Multiple-Choice Optionen (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Fülle mindestens 2 Felder aus, um ein Multiple-Choice-Rätsel zu erstellen. Die korrekte Antwort oben muss mit einer der Optionen übereinstimmen.'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _option1Controller,
                decoration: const InputDecoration(labelText: 'Antwort-Option 1'),
              ),
              TextFormField(
                controller: _option2Controller,
                decoration: const InputDecoration(labelText: 'Antwort-Option 2'),
              ),
              TextFormField(
                controller: _option3Controller,
                decoration: const InputDecoration(labelText: 'Antwort-Option 3 (optional)'),
              ),
              TextFormField(
                controller: _option4Controller,
                decoration: const InputDecoration(labelText: 'Antwort-Option 4 (optional)'),
              ),
            ],
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
