// lib/features/admin/admin_editor_screen.dart

import 'dart:io';
import 'package:clue_master/data/models/hunt.dart';
import 'package:clue_master/data/models/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/clue.dart';

class AdminEditorScreen extends StatefulWidget {
  final Hunt hunt;
  final String? codeToEdit;
  final Clue? existingClue;
  final Function(Map<String, Clue>) onSave;
  final List<String> existingCodes;

  const AdminEditorScreen({
    super.key,
    required this.hunt,
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
  final _uuid = Uuid();
  bool _isRecording = false;

  // --- Basis-Controller ---
  final _codeController = TextEditingController();
  String _type = 'text';
  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isFinalClue = false;
  ImageEffect _imageEffect = ImageEffect.NONE;
  TextEffect _textEffect = TextEffect.NONE;

  // --- Rätsel-Controller ---
  bool _isRiddle = false;
  RiddleType _riddleType = RiddleType.TEXT;
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _hint1Controller = TextEditingController();
  final _hint2Controller = TextEditingController();
  final _rewardTextController = TextEditingController();
  final _nextClueCodeController = TextEditingController();
  bool _autoTriggerNextClue = true;
  
  // --- Item-Controller ---
  String? _selectedRewardItemId;
  String? _selectedRequiredItemId;

  // --- Controller für Entscheidungs-Rätsel ---
  final _decisionCode1Controller = TextEditingController();
  final _decisionCode2Controller = TextEditingController();
  final _decisionCode3Controller = TextEditingController();
  final _decisionCode4Controller = TextEditingController();

  // --- GPS-Controller ---
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController();
  bool _isFetchingLocation = false;
  String? _backgroundImagePath;


  @override
  void initState() {
    super.initState();
    if (widget.existingClue != null) {
      final clue = widget.existingClue!;
      _codeController.text = clue.code;
      _type = clue.type;
      _contentController.text = clue.content;
      _descriptionController.text = clue.description ?? '';
      _isFinalClue = clue.isFinalClue;
      _imageEffect = clue.imageEffect;
      _textEffect = clue.textEffect;
      _isRiddle = clue.isRiddle;
      _backgroundImagePath = clue.backgroundImagePath;
      _selectedRequiredItemId = clue.requiredItemId;

      if (clue.isRiddle) {
        _questionController.text = clue.question!;
        _rewardTextController.text = clue.rewardText ?? '';
        _riddleType = clue.riddleType;
        _nextClueCodeController.text = clue.nextClueCode ?? '';
        _autoTriggerNextClue = clue.autoTriggerNextClue;
        _selectedRewardItemId = clue.rewardItemId;

        if (clue.riddleType == RiddleType.GPS) {
          _latitudeController.text = clue.latitude?.toString() ?? '';
          _longitudeController.text = clue.longitude?.toString() ?? '';
          _radiusController.text = clue.radius?.toString() ?? '';
        } else if (clue.isDecisionRiddle) {
          _option1Controller.text = clue.options![0];
          _decisionCode1Controller.text = clue.decisionNextClueCodes![0];
          _option2Controller.text = clue.options!.length > 1 ? clue.options![1] : '';
          _decisionCode2Controller.text = clue.decisionNextClueCodes!.length > 1 ? clue.decisionNextClueCodes![1] : '';
          _option3Controller.text = clue.options!.length > 2 ? clue.options![2] : '';
          _decisionCode3Controller.text = clue.decisionNextClueCodes!.length > 2 ? clue.decisionNextClueCodes![2] : '';
          _option4Controller.text = clue.options!.length > 3 ? clue.options![3] : '';
          _decisionCode4Controller.text = clue.decisionNextClueCodes!.length > 3 ? clue.decisionNextClueCodes![3] : '';
        }
        else { 
          _answerController.text = clue.answer ?? '';
          _hint1Controller.text = clue.hint1 ?? '';
          _hint2Controller.text = clue.hint2 ?? '';
          if (clue.isMultipleChoice) {
            _riddleType = RiddleType.MULTIPLE_CHOICE;
            _option1Controller.text = clue.options![0];
            _option2Controller.text = clue.options!.length > 1 ? clue.options![1] : '';
            _option3Controller.text = clue.options!.length > 2 ? clue.options![2] : '';
            _option4Controller.text = clue.options!.length > 3 ? clue.options![3] : '';
          }
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
    _nextClueCodeController.dispose();
    _audioRecorder.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    _decisionCode1Controller.dispose();
    _decisionCode2Controller.dispose();
    _decisionCode3Controller.dispose();
    _decisionCode4Controller.dispose();
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
      
      final decisionCodes = [
        _decisionCode1Controller.text.trim(),
        _decisionCode2Controller.text.trim(),
        _decisionCode3Controller.text.trim(),
        _decisionCode4Controller.text.trim(),
      ].sublist(0, options.length);

      final clue = Clue(
        code: _codeController.text.trim(),
        type: _type,
        content: _contentController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        isFinalClue: _isFinalClue,
        imageEffect: _type == 'image' ? _imageEffect : ImageEffect.NONE,
        textEffect: _type == 'text' ? _textEffect : TextEffect.NONE,
        
        question: _isRiddle ? _questionController.text.trim() : null,
        
        rewardText: _isRiddle && _rewardTextController.text.trim().isNotEmpty ? _rewardTextController.text.trim() : null,
        nextClueCode: _isRiddle && _nextClueCodeController.text.trim().isNotEmpty ? _nextClueCodeController.text.trim() : null,
        
        autoTriggerNextClue: _autoTriggerNextClue,
        
        rewardItemId: _isRiddle ? _selectedRewardItemId : null,
        requiredItemId: _selectedRequiredItemId,

        riddleType: _isRiddle ? _riddleType : RiddleType.TEXT,
        answer: _isRiddle && _riddleType != RiddleType.GPS && _riddleType != RiddleType.DECISION ? _answerController.text.trim() : null,
        options: _isRiddle && (_riddleType == RiddleType.MULTIPLE_CHOICE || _riddleType == RiddleType.DECISION) ? options : null,
        
        decisionNextClueCodes: _isRiddle && _riddleType == RiddleType.DECISION ? decisionCodes : null,

        hint1: _isRiddle && _riddleType != RiddleType.GPS && _riddleType != RiddleType.DECISION && _hint1Controller.text.trim().isNotEmpty ? _hint1Controller.text.trim() : null,
        hint2: _isRiddle && _riddleType != RiddleType.GPS && _riddleType != RiddleType.DECISION && _hint2Controller.text.trim().isNotEmpty ? _hint2Controller.text.trim() : null,
        latitude: _isRiddle && _riddleType == RiddleType.GPS ? double.tryParse(_latitudeController.text) : null,
        longitude: _isRiddle && _riddleType == RiddleType.GPS ? double.tryParse(_longitudeController.text) : null,
        radius: _isRiddle && _riddleType == RiddleType.GPS ? double.tryParse(_radiusController.text) : null,
        backgroundImagePath: _isRiddle && _riddleType == RiddleType.GPS ? _backgroundImagePath : null,
      );

      final updatedMap = {clue.code: clue};
      widget.onSave(updatedMap);
      Navigator.pop(context);
    }
  }
  
  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      var permission = await Permission.location.request();
      if (permission.isGranted) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _latitudeController.text = position.latitude.toString();
          _longitudeController.text = position.longitude.toString();
        });
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Standort-Berechtigung wurde verweigert.'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Standort konnte nicht abgerufen werden: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if(mounted) {
        setState(() => _isFetchingLocation = false);
      }
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
      if(mounted) {
        setState(() => _isRecording = false);
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        await _audioRecorder.start(const RecordConfig(), path: '${dir.path}/temp_audio');
        if(mounted) {
          setState(() => _isRecording = true);
        }
      }
    }
  }

  Future<void> _saveMediaFile(String originalPath, String originalName, TextEditingController controller) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$originalName';
    final newPath = '${dir.path}/$fileName';
    await File(originalPath).copy(newPath);
    if(mounted) {
      setState(() {
        controller.text = 'file://$newPath';
      });
    }
  }
  
  Future<void> _pickGpsBackgroundImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileExtension = path.extension(image.path);
      final String newFileName = '${_uuid.v4()}$fileExtension';
      final String savedImagePath = path.join(appDir.path, newFileName);

      await File(image.path).copy(savedImagePath);

      if(mounted) {
        setState(() {
          _backgroundImagePath = savedImagePath;
        });
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern des Bildes: $e')),
        );
      }
    }
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
            _buildSectionHeader('Basis-Informationen'),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Eindeutiger Code der Station'),
              validator: (value) {
                final code = value?.trim() ?? '';
                if (code.isEmpty) return 'Der Code ist ein Pflichtfeld.';
                if (widget.codeToEdit == null && widget.existingCodes.contains(code)) return 'Dieser Code existiert bereits.';
                if (widget.codeToEdit != null && code != widget.codeToEdit && widget.existingCodes.contains(code)) return 'Dieser Code existiert bereits.';
                return null;
              },
            ),
             _buildItemDropdown(
              label: 'Benötigtes Item (optional)',
              hint: 'Spieler muss dieses Item besitzen, um den Inhalt zu sehen',
              currentValue: _selectedRequiredItemId,
              onChanged: (itemId) {
                setState(() {
                  _selectedRequiredItemId = itemId;
                });
              },
            ),

            const Divider(height: 40, thickness: 1),
            _buildSectionHeader('Stations-Inhalt'),
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
              decoration: const InputDecoration(labelText: 'Typ des Inhalts'),
            ),
            const SizedBox(height: 8),
            _buildMediaContentField(),
            
            const Divider(height: 40, thickness: 1),
            CheckboxListTile(
              title: const Text('Optionales Rätsel hinzufügen'),
              subtitle: const Text('Der Spieler muss nach dem Inhalt eine Aufgabe lösen.'),
              value: _isRiddle,
              onChanged: (value) => setState(() => _isRiddle = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_isRiddle) _buildRiddleSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiddleSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Rätsel-Details'),
          TextFormField(
            controller: _questionController,
            decoration: const InputDecoration(labelText: 'Aufgabenstellung / Frage', hintText: 'z.B. Welchen Weg schlägst du ein?'),
            validator: (v) => (_isRiddle && (v == null || v.isEmpty)) ? 'Aufgabenstellung erforderlich' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<RiddleType>(
            value: _riddleType,
            items: const [
              DropdownMenuItem(value: RiddleType.TEXT, child: Text('Text-Antwort')),
              DropdownMenuItem(value: RiddleType.MULTIPLE_CHOICE, child: Text('Multiple-Choice')),
              DropdownMenuItem(value: RiddleType.DECISION, child: Text('Entscheidung (Verzweigung)')),
              DropdownMenuItem(value: RiddleType.GPS, child: Text('GPS-Ort finden')),
            ],
            onChanged: (value) => setState(() => _riddleType = value!),
            decoration: const InputDecoration(labelText: 'Art des Rätsels'),
          ),
          const SizedBox(height: 16),
          
          if (_riddleType == RiddleType.GPS)
            _buildGpsRiddleFields()
          else if (_riddleType == RiddleType.DECISION)
             _buildDecisionRiddleFields()
          else
            _buildTextRiddleFields(),

          const Divider(height: 40, thickness: 1),
          _buildSectionHeader('Belohnung & Nächster Schritt'),
          
           _buildItemDropdown(
            label: 'Belohnungs-Item (optional)',
            hint: 'Spieler erhält dieses Item nach dem Lösen des Rätsels',
            currentValue: _selectedRewardItemId,
            onChanged: (itemId) {
              setState(() {
                _selectedRewardItemId = itemId;
              });
            },
          ),
          const SizedBox(height: 16),
          
          CheckboxListTile(
            title: const Text('Dies ist der finale Hinweis der Mission'),
            subtitle: const Text('Löst der Spieler dieses Rätsel, ist die Jagd beendet.'),
            value: _isFinalClue,
            onChanged: (value) => setState(() => _isFinalClue = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _rewardTextController,
            decoration: InputDecoration(
              labelText: _isFinalClue ? 'Finaler Erfolgs-Text' : 'Belohnungs-Text (optional)', 
              hintText: 'z.B. Gut gemacht, Agent!', 
            ),
            maxLines: 3,
            validator: (v) {
              if (_isRiddle && _isFinalClue && (v == null || v.isEmpty)) {
                return 'Finaler Text ist für den letzten Hinweis erforderlich.';
              }
              return null;
            },
          ),
          
          if (!_isFinalClue && _riddleType != RiddleType.DECISION) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _nextClueCodeController,
              decoration: const InputDecoration(
                labelText: 'Code für nächsten Hinweis (optional)',
                hintText: 'z.B. ADLER3',
              ),
            ),
            CheckboxListTile(
              title: const Text('Nächsten Hinweis automatisch starten'),
              subtitle: const Text('Animiert die Eingabe des nächsten Codes.'),
              value: _autoTriggerNextClue,
              onChanged: (value) {
                setState(() {
                  _autoTriggerNextClue = value ?? true;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDecisionRiddleFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Entscheidungs-Optionen & Ziel-Codes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Gib bis zu 4 Optionen an. Für jede Option muss ein gültiger Ziel-Code einer anderen Station eingegeben werden.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        _buildDecisionOptionRow(1, _option1Controller, _decisionCode1Controller),
        _buildDecisionOptionRow(2, _option2Controller, _decisionCode2Controller),
        _buildDecisionOptionRow(3, _option3Controller, _decisionCode3Controller),
        _buildDecisionOptionRow(4, _option4Controller, _decisionCode4Controller),
      ],
    );
  }

  Widget _buildDecisionOptionRow(int number, TextEditingController optionController, TextEditingController codeController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: optionController,
              decoration: InputDecoration(labelText: 'Text für Option $number'),
              validator: (v) {
                if (codeController.text.isNotEmpty && (v == null || v.isEmpty)) {
                  return 'Text erforderlich';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: codeController,
              decoration: InputDecoration(labelText: 'Ziel-Code für Option $number'),
              validator: (v) {
                 if (optionController.text.isNotEmpty && (v == null || v.isEmpty)) {
                  return 'Ziel-Code erforderlich';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDropdown({
    required String label,
    required String hint,
    required String? currentValue,
    required ValueChanged<String?> onChanged,
  }) {
    final items = widget.hunt.items.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final dropdownItems = [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Kein Item', style: TextStyle(fontStyle: FontStyle.italic)),
      ),
      ...items.map((item) {
        return DropdownMenuItem<String>(
          value: item.id,
          child: Text(item.name),
        );
      }),
    ];

    return DropdownButtonFormField<String>(
      value: currentValue,
      items: dropdownItems,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
  
  Widget _buildTextRiddleFields() {
    return Column(
      children: [
        TextFormField(
          controller: _answerController,
          decoration: const InputDecoration(labelText: 'Korrekte Antwort'),
          validator: (v) => (_riddleType != RiddleType.GPS && _isRiddle && (v == null || v.isEmpty)) ? 'Antwort erforderlich' : null,
        ),
        const SizedBox(height: 16),
        if (_riddleType == RiddleType.MULTIPLE_CHOICE)
          _buildMultipleChoiceFields(),
        const SizedBox(height: 16),
        _buildSectionHeader('Gestaffelte Hilfe (Optional)'),
        TextFormField(controller: _hint1Controller, decoration: const InputDecoration(labelText: 'Hilfe nach 2 Fehlversuchen')),
        const SizedBox(height: 8),
        TextFormField(controller: _hint2Controller, decoration: const InputDecoration(labelText: 'Hilfe nach 4 Fehlversuchen')),
      ],
    );
  }

  Widget _buildGpsRiddleFields() {
    return Column(
      children: [
        TextFormField(
          controller: _latitudeController,
          decoration: const InputDecoration(labelText: 'Breitengrad (Latitude)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => (_riddleType == RiddleType.GPS && (v == null || v.isEmpty)) ? 'Breitengrad erforderlich' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _longitudeController,
          decoration: const InputDecoration(labelText: 'Längengrad (Longitude)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => (_riddleType == RiddleType.GPS && (v == null || v.isEmpty)) ? 'Längengrad erforderlich' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _radiusController,
          decoration: const InputDecoration(labelText: 'Radius in Metern', hintText: 'z.B. 20'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => (_riddleType == RiddleType.GPS && (v == null || v.isEmpty)) ? 'Radius erforderlich' : null,
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
        _buildGpsBackgroundSection(),
      ],
    );
  }

  Widget _buildGpsBackgroundSection() {
    final hasImage = _backgroundImagePath != null && _backgroundImagePath!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
            child: Text(
              "GPS-Hintergrund (optional)",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          if (hasImage)
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(_backgroundImagePath!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    label: const Text('Bild entfernen', style: TextStyle(color: Colors.redAccent)),
                    onPressed: () {
                      setState(() {
                        _backgroundImagePath = null;
                      });
                    },
                  ),
                ],
              ),
            )
          else
            Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Hintergrundbild wählen'),
                onPressed: _pickGpsBackgroundImage,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
    );
  }

  Widget _buildMediaContentField() {
    return Column(
      children: [
        if (_type == 'text')
          ...[
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Inhalt (Text)'),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Inhalt erforderlich' : null,
            ),
            const SizedBox(height: 8),
            _buildTextEffectField(),
            TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Beschreibung (optional)')),
          ]
        else
          ...[
            TextFormField(
              controller: _contentController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Dateipfad (${_type})'),
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
            if (_type == 'image')
              _buildImageEffectField(),
            TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Beschreibung (optional)')),
          ]
      ],
    );
  }
  
  Widget _buildImageEffectField() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: DropdownButtonFormField<ImageEffect>(
        value: _imageEffect,
        items: const [
          DropdownMenuItem(value: ImageEffect.NONE, child: Text('Kein Effekt')),
          DropdownMenuItem(value: ImageEffect.PUZZLE, child: Text('Puzzle (9 Teile)')),
          DropdownMenuItem(value: ImageEffect.INVERT_COLORS, child: Text('Farben invertieren')),
          DropdownMenuItem(value: ImageEffect.BLACK_AND_WHITE, child: Text('Schwarz-Weiß')),
        ],
        onChanged: (value) => setState(() => _imageEffect = value!),
        decoration: const InputDecoration(labelText: 'Optionaler Bild-Effekt'),
      ),
    );
  }

  Widget _buildTextEffectField() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: DropdownButtonFormField<TextEffect>(
        value: _textEffect,
        items: const [
          DropdownMenuItem(value: TextEffect.NONE, child: Text('Kein Effekt')),
          DropdownMenuItem(value: TextEffect.MORSE_CODE, child: Text('Morsecode')),
          DropdownMenuItem(value: TextEffect.REVERSE, child: Text('Text rückwärts')),
          DropdownMenuItem(value: TextEffect.NO_VOWELS, child: Text('Ohne Vokale')),
          DropdownMenuItem(value: TextEffect.MIRROR_WORDS, child: Text('Wörter spiegeln')),
        ],
        onChanged: (value) => setState(() => _textEffect = value!),
        decoration: const InputDecoration(labelText: 'Optionaler Text-Effekt'),
      ),
    );
  }

  Widget _buildMultipleChoiceFields() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Text('Multiple-Choice Optionen', style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 8),
      TextFormField(controller: _option1Controller, decoration: const InputDecoration(labelText: 'Option 1')),
      const SizedBox(height: 8),
      TextFormField(controller: _option2Controller, decoration: const InputDecoration(labelText: 'Option 2')),
      const SizedBox(height: 8),
      TextFormField(controller: _option3Controller, decoration: const InputDecoration(labelText: 'Option 3')),
      const SizedBox(height: 8),
      TextFormField(controller: _option4Controller, decoration: const InputDecoration(labelText: 'Option 4')),
    ]);
  }
}