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
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  // --- Allgemeine Controller ---
  final _codeController = TextEditingController();

  // --- RÄTSEL Controller ---
  String _riddleType = 'text';
  final _riddleContentController = TextEditingController();
  final _riddleDescriptionController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _hint1Controller = TextEditingController();
  final _hint2Controller = TextEditingController();

  // --- BELOHNUNG Controller ---
  String _rewardType = 'text';
  final _rewardContentController = TextEditingController();
  final _rewardDescriptionController = TextEditingController();

  // ============================================================
  // SECTION: Lifecycle-Methoden
  // ============================================================
  @override
  void initState() {
    super.initState();
    if (widget.existingClue != null) {
      final clue = widget.existingClue!;
      _codeController.text = clue.code;
      
      // Rätsel-Daten laden
      _riddleType = clue.riddleType;
      _riddleContentController.text = clue.riddleContent;
      _riddleDescriptionController.text = clue.riddleDescription ?? '';
      _questionController.text = clue.question;
      _answerController.text = clue.answer;
      _hint1Controller.text = clue.hint1 ?? '';
      _hint2Controller.text = clue.hint2 ?? '';
      if (clue.isMultipleChoice) {
        _option1Controller.text = clue.options![0];
        _option2Controller.text = clue.options!.length > 1 ? clue.options![1] : '';
        _option3Controller.text = clue.options!.length > 2 ? clue.options![2] : '';
        _option4Controller.text = clue.options!.length > 3 ? clue.options![3] : '';
      }

      // Belohnungs-Daten laden
      _rewardType = clue.rewardType;
      _rewardContentController.text = clue.rewardContent;
      _rewardDescriptionController.text = clue.rewardDescription ?? '';
    }
  }

  @override
  void dispose() {
    // Alle Controller freigeben
    _codeController.dispose();
    _riddleContentController.dispose();
    _riddleDescriptionController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _hint1Controller.dispose();
    _hint2Controller.dispose();
    _rewardContentController.dispose();
    _rewardDescriptionController.dispose();
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
        
        // Rätsel-Daten
        riddleType: _riddleType,
        riddleContent: _riddleContentController.text.trim(),
        riddleDescription: _riddleDescriptionController.text.trim().isEmpty ? null : _riddleDescriptionController.text.trim(),
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        isMultipleChoice: options.length >= 2,
        options: options.isNotEmpty ? options : null,
        hint1: _hint1Controller.text.trim().isEmpty ? null : _hint1Controller.text.trim(),
        hint2: _hint2Controller.text.trim().isEmpty ? null : _hint2Controller.text.trim(),
        
        // Belohnungs-Daten
        rewardType: _rewardType,
        rewardContent: _rewardContentController.text.trim(),
        rewardDescription: _rewardDescriptionController.text.trim().isEmpty ? null : _rewardDescriptionController.text.trim(),
      );

      final updatedMap = {clue.code: clue};
      widget.onSave(updatedMap);
      Navigator.pop(context);
    }
  }

  // Hilfsmethode, um Medien auszuwählen (Bild/Video/Audio)
  Future<void> _pickMedia(String target) async {
    // `target` kann 'riddle' oder 'reward' sein
    final contentController = target == 'riddle' ? _riddleContentController : _rewardContentController;
    final typeController = target == 'riddle' ? _riddleType : _rewardType;

    XFile? mediaFile;
    if (typeController == 'image') {
      mediaFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    } else if (typeController == 'video') {
      mediaFile = await _imagePicker.pickVideo(source: ImageSource.gallery);
    }
    
    if (mediaFile != null) {
      await _saveMediaFile(mediaFile.path, mediaFile.name, contentController);
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

  // ... (Andere Methoden wie _scanQrCode, _toggleRecording bleiben ähnlich, werden aber angepasst)
  
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
            // --- Allgemeiner Code ---
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code der Station'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Code erforderlich' : null,
            ),
            const SizedBox(height: 24),

            // --- RÄTSEL-SEKTION ---
            _buildSectionHeader('1. Das Rätsel (Was der Spieler sieht)'),
            _buildMediaTypeSelector('riddle'),
            _buildMediaContentField('riddle'),
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Frage zum Rätsel-Inhalt'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Frage erforderlich' : null,
            ),
            TextFormField(
              controller: _answerController,
              decoration: const InputDecoration(labelText: 'Korrekte Antwort'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Antwort erforderlich' : null,
            ),
            const SizedBox(height: 16),
            _buildMultipleChoiceFields(),
            const SizedBox(height: 24),

            // --- HILFE-SEKTION ---
            _buildSectionHeader('2. Gestaffelte Hilfe (Optional)'),
            TextFormField(
              controller: _hint1Controller,
              decoration: const InputDecoration(labelText: 'Hilfe nach 3 falschen Versuchen'),
            ),
            TextFormField(
              controller: _hint2Controller,
              decoration: const InputDecoration(labelText: 'Hilfe nach 6 falschen Versuchen'),
            ),
            const SizedBox(height: 24),

            // --- BELOHNUNGS-SEKTION ---
            _buildSectionHeader('3. Die Belohnung (Was der Spieler danach erhält)'),
            _buildMediaTypeSelector('reward'),
            _buildMediaContentField('reward'),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION: UI-Hilfsmethoden
  // ============================================================
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildMediaTypeSelector(String target) {
    final isRiddle = target == 'riddle';
    return DropdownButtonFormField<String>(
      value: isRiddle ? _riddleType : _rewardType,
      items: const [
        DropdownMenuItem(value: 'text', child: Text('Text')),
        DropdownMenuItem(value: 'image', child: Text('Bild')),
        DropdownMenuItem(value: 'audio', child: Text('Audio')),
        DropdownMenuItem(value: 'video', child: Text('Video')),
      ],
      onChanged: (value) {
        setState(() {
          if (isRiddle) {
            _riddleType = value!;
            _riddleContentController.clear();
          } else {
            _rewardType = value!;
            _rewardContentController.clear();
          }
        });
      },
      decoration: InputDecoration(labelText: 'Typ für ${isRiddle ? 'Rätsel' : 'Belohnung'}'),
    );
  }

  Widget _buildMediaContentField(String target) {
    final isRiddle = target == 'riddle';
    final type = isRiddle ? _riddleType : _rewardType;
    final contentController = isRiddle ? _riddleContentController : _rewardContentController;
    final descriptionController = isRiddle ? _riddleDescriptionController : _rewardDescriptionController;

    if (type == 'text') {
      return Column(
        children: [
          TextFormField(
            controller: contentController,
            decoration: InputDecoration(labelText: '${isRiddle ? 'Rätsel' : 'Belohnungs'}-Text'),
            maxLines: 3,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Inhalt erforderlich' : null,
          ),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Beschreibung (optional)'),
          ),
        ],
      );
    } else {
      // Für Bild, Audio, Video
      return Column(
        children: [
          TextFormField(
            controller: contentController,
            readOnly: true,
            decoration: InputDecoration(labelText: 'Dateipfad (${type})'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Datei erforderlich' : null,
          ),
          ElevatedButton(
            onPressed: () => _pickMedia(target),
            child: Text('${type.capitalize()} aus Galerie wählen'),
          ),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Beschreibung (optional)'),
          ),
        ],
      );
    }
  }

  Widget _buildMultipleChoiceFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Multiple-Choice Optionen (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('Fülle mind. 2 Felder aus. Die korrekte Antwort oben muss mit einer Option übereinstimmen.'),
        TextFormField(controller: _option1Controller, decoration: const InputDecoration(labelText: 'Option 1')),
        TextFormField(controller: _option2Controller, decoration: const InputDecoration(labelText: 'Option 2')),
        TextFormField(controller: _option3Controller, decoration: const InputDecoration(labelText: 'Option 3')),
        TextFormField(controller: _option4Controller, decoration: const InputDecoration(labelText: 'Option 4')),
      ],
    );
  }
}

// Hilfsklasse zur einfachen Großschreibung
extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${this.substring(1)}";
    }
}

// Hilfsklasse zur Umwandlung in Großbuchstaben
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
