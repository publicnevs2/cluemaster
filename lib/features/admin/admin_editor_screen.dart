// lib/features/admin/admin_editor_screen.dart

import 'dart:io';
import 'package:clue_master/data/models/hunt.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/clue.dart';
import 'widgets/clue_basic_info_section.dart';
import 'widgets/clue_content_section.dart';
import 'widgets/clue_riddle_section.dart'; // NEUER IMPORT

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
        } else {
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Standort-Berechtigung wurde verweigert.'),
            backgroundColor: Colors.red,
          ));//..
          
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Standort konnte nicht abgerufen werden: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
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
      if (mounted) {
        setState(() => _isRecording = false);
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        await _audioRecorder.start(const RecordConfig(), path: '${dir.path}/temp_audio');
        if (mounted) {
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
    if (mounted) {
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

      if (mounted) {
        setState(() {
          _backgroundImagePath = savedImagePath;
        });
      }
    } catch (e) {
      if (mounted) {
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
            ClueBasicInfoSection(
              codeController: _codeController,
              codeToEdit: widget.codeToEdit,
              existingCodes: widget.existingCodes,
              selectedRequiredItemId: _selectedRequiredItemId,
              hunt: widget.hunt,
              onRequiredItemChanged: (itemId) {
                setState(() {
                  _selectedRequiredItemId = itemId;
                });
              },
            ),
            const Divider(height: 40, thickness: 1),
            ClueContentSection(
              type: _type,
              onTypeChanged: (value) => setState(() {
                _type = value!;
                _contentController.clear();
              }),
              contentController: _contentController,
              descriptionController: _descriptionController,
              imageEffect: _imageEffect,
              onImageEffectChanged: (value) => setState(() => _imageEffect = value!),
              textEffect: _textEffect,
              onTextEffectChanged: (value) => setState(() => _textEffect = value!),
              isRecording: _isRecording,
              onPickMedia: _pickMedia,
              onToggleRecording: _toggleRecording,
            ),
            const Divider(height: 40, thickness: 1),
            CheckboxListTile(
              title: const Text('Optionales Rätsel hinzufügen'),
              subtitle: const Text('Der Spieler muss nach dem Inhalt eine Aufgabe lösen.'),
              value: _isRiddle,
              onChanged: (value) => setState(() => _isRiddle = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_isRiddle)
              ClueRiddleSection(
                questionController: _questionController,
                answerController: _answerController,
                hint1Controller: _hint1Controller,
                hint2Controller: _hint2Controller,
                option1Controller: _option1Controller,
                option2Controller: _option2Controller,
                option3Controller: _option3Controller,
                option4Controller: _option4Controller,
                decisionCode1Controller: _decisionCode1Controller,
                decisionCode2Controller: _decisionCode2Controller,
                decisionCode3Controller: _decisionCode3Controller,
                decisionCode4Controller: _decisionCode4Controller,
                latitudeController: _latitudeController,
                longitudeController: _longitudeController,
                radiusController: _radiusController,
                rewardTextController: _rewardTextController,
                nextClueCodeController: _nextClueCodeController,
                riddleType: _riddleType,
                isFetchingLocation: _isFetchingLocation,
                backgroundImagePath: _backgroundImagePath,
                selectedRewardItemId: _selectedRewardItemId,
                isFinalClue: _isFinalClue,
                autoTriggerNextClue: _autoTriggerNextClue,
                hunt: widget.hunt,
                onRiddleTypeChanged: (value) => setState(() => _riddleType = value!),
                onGetCurrentLocation: _getCurrentLocation,
                onPickGpsBackgroundImage: _pickGpsBackgroundImage,
                onRemoveGpsBackgroundImage: () => setState(() => _backgroundImagePath = null),
                onRewardItemChanged: (itemId) => setState(() => _selectedRewardItemId = itemId),
                onFinalClueChanged: (value) => setState(() => _isFinalClue = value ?? false),
                onAutoTriggerChanged: (value) => setState(() => _autoTriggerNextClue = value ?? true),
              ),
          ],
        ),
      ),
    );
  }
}
