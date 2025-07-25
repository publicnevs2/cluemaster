import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:geolocator/geolocator.dart'; // NEU: Import für GPS
import 'package:permission_handler/permission_handler.dart'; // NEU: Import für Berechtigungen

import '../../data/models/clue.dart';

class AdminEditorScreen extends StatefulWidget {
  final String? codeToEdit;
  final Clue? existingClue;
  final Function(Map<String, Clue>) onSave;
  final List<String> existingCodes;

  const AdminEditorScreen({
    super.key,
    this.codeToEdit,
    this.existingClue,
    required this.onSave,
    this.existingCodes = const [],
  });

  @override
  State<AdminEditorScreen> createState() => _AdminEditorScreenState();
}

class _AdminEditorScreenState extends State<AdminEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  // --- Bestehende Controller ---
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
  bool _isFinalClue = false;

  // --- NEUE Controller und Variablen für GPS ---
  UnlockMethod _unlockMethod = UnlockMethod.CODE;
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController();
  bool _isFetchingLocation = false;


  @override
  void initState() {
    super.initState();
    if (widget.existingClue != null) {
      final clue = widget.existingClue!;
      _codeController.text = clue.code;
      _type = clue.type;
      _contentController.text = clue.content;
      _descriptionController.text = clue.description ?? '';
      _isRiddle = clue.isRiddle;
      _isFinalClue = clue.isFinalClue;
      
      // NEU: GPS-Felder initialisieren
      _unlockMethod = clue.unlockMethod;
      if (clue.isGpsClue) {
        _latitudeController.text = clue.latitude.toString();
        _longitudeController.text = clue.longitude.toString();
        _radiusController.text = clue.radius.toString();
      }

      if (clue.isRiddle) {
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
    // Alle Controller entsorgen
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
    // NEU: GPS-Controller entsorgen
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

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
        isFinalClue: _isFinalClue,
        // NEU: GPS-Daten speichern
        unlockMethod: _unlockMethod,
        latitude: _unlockMethod == UnlockMethod.GPS ? double.tryParse(_latitudeController.text) : null,
        longitude: _unlockMethod == UnlockMethod.GPS ? double.tryParse(_longitudeController.text) : null,
        radius: _unlockMethod == UnlockMethod.GPS ? double.tryParse(_radiusController.text) : null,
      );

      final updatedMap = {clue.code: clue};
      widget.onSave(updatedMap);
      Navigator.pop(context);
    }
  }
  
  // --- NEUE METHODE: Aktuellen Standort abrufen ---
  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      // 1. Berechtigung prüfen
      var permission = await Permission.location.request();
      if (permission.isGranted) {
        // 2. Standort abrufen
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        
        // 3. Controller aktualisieren
        setState(() {
          _latitudeController.text = position.latitude.toString();
          _longitudeController.text = position.longitude.toString();
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Standort-Berechtigung wurde verweigert.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Standort konnte nicht abgerufen werden: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _isFetchingLocation = false);
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
            _buildSectionHeader('Freischalt-Methode'),
            DropdownButtonFormField<UnlockMethod>(
              value: _unlockMethod,
              items: const [
                DropdownMenuItem(value: UnlockMethod.CODE, child: Text('Code / QR-Code')),
                DropdownMenuItem(value: UnlockMethod.GPS, child: Text('GPS-Standort')),
              ],
              onChanged: (value) => setState(() => _unlockMethod = value!),
              decoration: const InputDecoration(labelText: 'Wie wird die Station freigeschaltet?', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
            ),

            const Divider(height: 40, thickness: 1),

            // --- Bedingte Anzeige der Felder ---
            if (_unlockMethod == UnlockMethod.CODE)
              _buildCodeSection()
            else
              _buildGpsSection(),

            const Divider(height: 40, thickness: 1),
            
            _buildSectionHeader('Stations-Inhalt (wird nach Freischaltung angezeigt)'),
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
              decoration: const InputDecoration(labelText: 'Typ des Inhalts', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
            ),
            const SizedBox(height: 8),
            _buildMediaContentField(),
            
            const Divider(height: 40, thickness: 1),
            CheckboxListTile(
              title: const Text('Optionales Rätsel hinzufügen'),
              subtitle: const Text('Wenn aktiviert, muss der Spieler erst eine Frage beantworten.'),
              value: _isRiddle,
              onChanged: (value) => setState(() => _isRiddle = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_isRiddle) ...[
              _buildSectionHeader('Rätsel-Details'),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Frage zum Hinweis', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
                validator: (v) => (_isRiddle && (v == null || v.isEmpty)) ? 'Frage erforderlich' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Korrekte Antwort', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
                validator: (v) => (_isRiddle && (v == null || v.isEmpty)) ? 'Antwort erforderlich' : null,
              ),
              const SizedBox(height: 16),
              _buildMultipleChoiceFields(),
              const SizedBox(height: 16),
              _buildSectionHeader('Gestaffelte Hilfe (Optional)'),
              TextFormField(controller: _hint1Controller, decoration: const InputDecoration(labelText: 'Hilfe nach 2 Fehlversuchen', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12))),
              const SizedBox(height: 8),
              TextFormField(controller: _hint2Controller, decoration: const InputDecoration(labelText: 'Hilfe nach 4 Fehlversuchen', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12))),
              const SizedBox(height: 16),
              
              const Divider(height: 40, thickness: 1),
              _buildSectionHeader('Belohnung / Finale'),
              CheckboxListTile(
                title: const Text('Dies ist der finale Hinweis der Mission'),
                subtitle: const Text('Löst der Spieler dieses Rätsel, ist die Jagd beendet.'),
                value: _isFinalClue,
                onChanged: (value) {
                  setState(() => _isFinalClue = value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8),
              Text(
                _isFinalClue 
                  ? 'Die finale Botschaft wird durch den "Stations-Inhalt" oben und den "Finalen Erfolgs-Text" unten definiert.'
                  : 'Die Belohnung wird durch den "Stations-Inhalt" oben und den "Belohnungs-Text" unten definiert.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rewardTextController,
                decoration: InputDecoration(
                  labelText: _isFinalClue ? 'Finaler Erfolgs-Text' : 'Belohnungs-Text', 
                  hintText: 'z.B. Schatz gefunden! Der Code für die Truhe ist 1234', 
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12)
                ),
                maxLines: 3,
                validator: (v) => (_isRiddle && (v == null || v.isEmpty)) ? 'Text erforderlich' : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- NEUE WIDGETS für die Sektionen ---
  Widget _buildCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Code-Einstellungen'),
        TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(labelText: 'Code der Station', hintText: 'z.B. A1, Baumhaus, etc.', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
          validator: (value) {
            final code = value?.trim() ?? '';
            if (code.isEmpty) {
              return 'Der Code ist ein Pflichtfeld.';
            }
            if (widget.codeToEdit == null && widget.existingCodes.contains(code)) {
              return 'Dieser Code existiert bereits.';
            }
            if (widget.codeToEdit != null && code != widget.codeToEdit && widget.existingCodes.contains(code)) {
              return 'Dieser Code existiert bereits.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGpsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('GPS-Einstellungen'),
        TextFormField(
          controller: _latitudeController,
          decoration: const InputDecoration(labelText: 'Breitengrad (Latitude)', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (v) => (_unlockMethod == UnlockMethod.GPS && (v == null || v.isEmpty)) ? 'Breitengrad erforderlich' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _longitudeController,
          decoration: const InputDecoration(labelText: 'Längengrad (Longitude)', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (v) => (_unlockMethod == UnlockMethod.GPS && (v == null || v.isEmpty)) ? 'Längengrad erforderlich' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _radiusController,
          decoration: const InputDecoration(labelText: 'Radius in Metern', hintText: 'z.B. 20', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => (_unlockMethod == UnlockMethod.GPS && (v == null || v.isEmpty)) ? 'Radius erforderlich' : null,
        ),
        const SizedBox(height: 16),
        Center(
          child: _isFetchingLocation 
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                icon: const Icon(Icons.my_location),
                label: const Text('Aktuellen Standort eintragen'),
                onPressed: _getCurrentLocation,
              ),
        ),
      ],
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
    );
  }

  Widget _buildMediaContentField() {
    if (_type == 'text') {
      return Column(children: [
        TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(labelText: 'Inhalt (Text)', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
          maxLines: 3,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Inhalt erforderlich' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Beschreibung (optional)', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12))),
      ]);
    } else {
      return Column(children: [
        TextFormField(
          controller: _contentController,
          readOnly: true,
          decoration: InputDecoration(labelText: 'Dateipfad (${_type})', contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
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
        const SizedBox(height: 8),
        TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Beschreibung (optional)', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12))),
      ]);
    }
  }

  Widget _buildMultipleChoiceFields() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      const Text('Multiple-Choice Optionen (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
      TextFormField(controller: _option1Controller, decoration: const InputDecoration(labelText: 'Option 1', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12))),
      const SizedBox(height: 8),
      TextFormField(controller: _option2Controller, decoration: const InputDecoration(labelText: 'Option 2', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12))),
      const SizedBox(height: 8),
      TextFormField(controller: _option3Controller, decoration: const InputDecoration(labelText: 'Option 3', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12))),
      const SizedBox(height: 8),
      TextFormField(controller: _option4Controller, decoration: const InputDecoration(labelText: 'Option 4', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12))),
    ]);
  }
}
