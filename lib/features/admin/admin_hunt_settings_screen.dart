// lib/features/admin/admin_hunt_settings_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import '../../data/models/item.dart'; // NEU: Item-Modell importieren

class AdminHuntSettingsScreen extends StatefulWidget {
  final Hunt? hunt;
  final List<String> existingHuntNames;

  const AdminHuntSettingsScreen({
    super.key,
    this.hunt,
    this.existingHuntNames = const [],
  });

  @override
  State<AdminHuntSettingsScreen> createState() =>
      _AdminHuntSettingsScreenState();
}

class _AdminHuntSettingsScreenState extends State<AdminHuntSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clueService = ClueService();
  final _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _briefingTextController;
  late TextEditingController _targetTimeController;
  String? _briefingImagePath;

  // ============================================================
  // NEU: State für die ausgewählten Start-Items
  // ============================================================
  late Set<String> _selectedStartItemIds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hunt?.name ?? '');
    _briefingTextController =
        TextEditingController(text: widget.hunt?.briefingText ?? '');
    _targetTimeController = TextEditingController(
      text: widget.hunt?.targetTimeInMinutes?.toString() ?? '',
    );
    _briefingImagePath = widget.hunt?.briefingImageUrl;

    // NEU: Initialisiert das Set mit den bereits vorhandenen Start-Items
    _selectedStartItemIds = Set<String>.from(widget.hunt?.startingItemIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _briefingTextController.dispose();
    _targetTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = pickedFile.path.split('/').last;
      final savedImage =
          await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _briefingImagePath = 'file://${savedImage.path}';
      });
    }
  }

  Future<void> _saveHunt() async {
    if (_formKey.currentState!.validate()) {
      final allHunts = await _clueService.loadHunts();

      final targetTimeText = _targetTimeController.text.trim();
      final int? targetTime =
          targetTimeText.isNotEmpty ? int.tryParse(targetTimeText) : null;

      final updatedHunt = Hunt(
        name: _nameController.text.trim(),
        briefingText: _briefingTextController.text.trim().isEmpty
            ? null
            : _briefingTextController.text.trim(),
        briefingImageUrl: _briefingImagePath,
        targetTimeInMinutes: targetTime,
        clues: widget.hunt?.clues ?? {},
        // ============================================================
        // NEU: Speichert die Item-Daten mit ab
        // ============================================================
        items: widget.hunt?.items ?? {}, // Behält die Item-Bibliothek bei
        startingItemIds: _selectedStartItemIds.toList(), // Speichert die Auswahl
      );

      if (widget.hunt == null) {
        allHunts.add(updatedHunt);
      } else {
        final index = allHunts.indexWhere((h) => h.name == widget.hunt!.name);
        if (index != -1) {
          allHunts[index] = updatedHunt;
        }
      }

      await _clueService.saveHunts(allHunts);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hole alle verfügbaren Items für die Checkliste
    final allAvailableItems = widget.hunt?.items.values.toList() ?? [];
    allAvailableItems.sort((a,b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hunt == null
            ? 'Neue Jagd erstellen'
            : 'Jagd-Einstellungen'),
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
                if (widget.existingHuntNames.any((element) =>
                    element.toLowerCase() == name.toLowerCase() &&
                    name.toLowerCase() != widget.hunt?.name.toLowerCase())) {
                  return 'Eine Jagd mit diesem Namen existiert bereits.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetTimeController,
              decoration: const InputDecoration(
                labelText: 'Optionale Zielzeit (in Minuten)',
                hintText: 'z.B. 60 für eine Stunde',
                prefixIcon: Icon(Icons.timer_outlined),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            
            // ============================================================
            // NEU: Sektion für die Start-Ausrüstung
            // ============================================================
            const SizedBox(height: 24),
            Text('Start-Ausrüstung', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (allAvailableItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Du musst zuerst Items in der Item-Bibliothek anlegen, um sie hier auswählen zu können.', textAlign: TextAlign.center),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: allAvailableItems.map((item) {
                      return CheckboxListTile(
                        title: Text(item.name),
                        subtitle: Text(item.id, style: const TextStyle(color: Colors.grey)),
                        value: _selectedStartItemIds.contains(item.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedStartItemIds.add(item.id);
                            } else {
                              _selectedStartItemIds.remove(item.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            // ============================================================
            
            const SizedBox(height: 24),
            Text('Optionales Missions-Briefing', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _briefingTextController,
              decoration: const InputDecoration(
                labelText: 'Story-Einleitung',
                hintText: 'Agent 00Sven, Ihre Mission...',
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