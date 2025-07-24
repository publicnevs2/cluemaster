import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';

class AdminHuntSettingsScreen extends StatefulWidget {
  final Hunt? hunt;
  final List<String> existingHuntNames;

  const AdminHuntSettingsScreen({
    super.key,
    this.hunt,
    this.existingHuntNames = const [],
  });

  @override
  State<AdminHuntSettingsScreen> createState() => _AdminHuntSettingsScreenState();
}

class _AdminHuntSettingsScreenState extends State<AdminHuntSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clueService = ClueService();
  final _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _briefingTextController;
  String? _briefingImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hunt?.name ?? '');
    _briefingTextController = TextEditingController(text: widget.hunt?.briefingText ?? '');
    _briefingImagePath = widget.hunt?.briefingImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _briefingTextController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Kopiere die Datei in das App-Verzeichnis, um den Zugriff zu behalten
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = pickedFile.path.split('/').last;
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _briefingImagePath = 'file://${savedImage.path}';
      });
    }
  }

  Future<void> _saveHunt() async {
    if (_formKey.currentState!.validate()) {
      final allHunts = await _clueService.loadHunts();
      
      final updatedHunt = Hunt(
        name: _nameController.text.trim(),
        briefingText: _briefingTextController.text.trim().isEmpty ? null : _briefingTextController.text.trim(),
        briefingImageUrl: _briefingImagePath,
        // Behalte die existierenden Clues bei, wenn die Jagd bearbeitet wird
        clues: widget.hunt?.clues ?? {},
      );

      if (widget.hunt == null) {
        // Neue Jagd hinzufügen
        allHunts.add(updatedHunt);
      } else {
        // Bestehende Jagd aktualisieren
        final index = allHunts.indexWhere((h) => h.name == widget.hunt!.name);
        if (index != -1) {
          allHunts[index] = updatedHunt;
        }
      }

      await _clueService.saveHunts(allHunts);
      if (mounted) {
        Navigator.pop(context, true); // "true" signalisiert, dass die Liste neu geladen werden soll
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hunt == null ? 'Neue Jagd erstellen' : 'Jagd-Einstellungen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveHunt,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name der Jagd',
                hintText: 'z.B. Schatzsuche im Park',
              ),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) {
                  return 'Der Name darf nicht leer sein.';
                }
                if (widget.existingHuntNames.any((element) => element.toLowerCase() == name.toLowerCase())) {
                  return 'Eine Jagd mit diesem Namen existiert bereits.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('Optionales Missions-Briefing', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _briefingTextController,
              decoration: const InputDecoration(
                labelText: 'Story-Einleitung',
                hintText: 'Agent 00Sven, Ihre Mission, sollten Sie sie annehmen...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _briefingImagePath != null
                  ? Image.file(File(_briefingImagePath!.replaceFirst('file://', '')), fit: BoxFit.cover)
                  : const Center(child: Text('Kein Briefing-Bild')),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Bild auswählen'),
                ),
                const SizedBox(width: 8),
                if (_briefingImagePath != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _briefingImagePath = null),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Bild entfernen'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
