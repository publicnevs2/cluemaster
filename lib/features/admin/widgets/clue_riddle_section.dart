// lib/features/admin/widgets/clue_riddle_section.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/clue.dart';
import '../../../data/models/hunt.dart';

class ClueRiddleSection extends StatelessWidget {
  // Controllers
  final TextEditingController questionController;
  final TextEditingController answerController;
  final TextEditingController hint1Controller;
  final TextEditingController hint2Controller;
  final TextEditingController option1Controller;
  final TextEditingController option2Controller;
  final TextEditingController option3Controller;
  final TextEditingController option4Controller;
  final TextEditingController decisionCode1Controller;
  final TextEditingController decisionCode2Controller;
  final TextEditingController decisionCode3Controller;
  final TextEditingController decisionCode4Controller;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController radiusController;
  final TextEditingController rewardTextController;
  final TextEditingController nextClueCodeController;

  // State Variables
  final RiddleType riddleType;
  final bool isFetchingLocation;
  final String? backgroundImagePath;
  final String? selectedRewardItemId;
  final bool isFinalClue;
  final bool autoTriggerNextClue;
  final Hunt hunt;

  // Callbacks
  final Function(RiddleType?) onRiddleTypeChanged;
  final VoidCallback onGetCurrentLocation;
  final VoidCallback onPickGpsBackgroundImage;
  final VoidCallback onRemoveGpsBackgroundImage;
  final Function(String?) onRewardItemChanged;
  final Function(bool?) onFinalClueChanged;
  final Function(bool?) onAutoTriggerChanged;

  const ClueRiddleSection({
    super.key,
    required this.questionController,
    required this.answerController,
    required this.hint1Controller,
    required this.hint2Controller,
    required this.option1Controller,
    required this.option2Controller,
    required this.option3Controller,
    required this.option4Controller,
    required this.decisionCode1Controller,
    required this.decisionCode2Controller,
    required this.decisionCode3Controller,
    required this.decisionCode4Controller,
    required this.latitudeController,
    required this.longitudeController,
    required this.radiusController,
    required this.rewardTextController,
    required this.nextClueCodeController,
    required this.riddleType,
    required this.isFetchingLocation,
    this.backgroundImagePath,
    this.selectedRewardItemId,
    required this.isFinalClue,
    required this.autoTriggerNextClue,
    required this.hunt,
    required this.onRiddleTypeChanged,
    required this.onGetCurrentLocation,
    required this.onPickGpsBackgroundImage,
    required this.onRemoveGpsBackgroundImage,
    required this.onRewardItemChanged,
    required this.onFinalClueChanged,
    required this.onAutoTriggerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Rätsel-Details'),
          TextFormField(
            controller: questionController,
            decoration: const InputDecoration(labelText: 'Aufgabenstellung / Frage', hintText: 'z.B. Welchen Weg schlägst du ein?'),
            validator: (v) => (v == null || v.isEmpty) ? 'Aufgabenstellung erforderlich' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<RiddleType>(
            value: riddleType,
            items: const [
              DropdownMenuItem(value: RiddleType.TEXT, child: Text('Text-Antwort')),
              DropdownMenuItem(value: RiddleType.MULTIPLE_CHOICE, child: Text('Multiple-Choice')),
              DropdownMenuItem(value: RiddleType.DECISION, child: Text('Entscheidung (Verzweigung)')),
              DropdownMenuItem(value: RiddleType.GPS, child: Text('GPS-Ort finden')),
            ],
            onChanged: onRiddleTypeChanged,
            decoration: const InputDecoration(labelText: 'Art des Rätsels'),
          ),
          const SizedBox(height: 16),
          if (riddleType == RiddleType.GPS)
            _buildGpsRiddleFields(context)
          else if (riddleType == RiddleType.DECISION)
            _buildDecisionRiddleFields(context)
          else
            _buildTextRiddleFields(context),
          const Divider(height: 40, thickness: 1),
          _buildSectionHeader(context, 'Belohnung & Nächster Schritt'),
          _buildItemDropdown(
            label: 'Belohnungs-Item (optional)',
            hint: 'Spieler erhält dieses Item nach dem Lösen des Rätsels',
            currentValue: selectedRewardItemId,
            onChanged: onRewardItemChanged,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Dies ist der finale Hinweis der Mission'),
            subtitle: const Text('Löst der Spieler dieses Rätsel, ist die Jagd beendet.'),
            value: isFinalClue,
            onChanged: onFinalClueChanged,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: rewardTextController,
            decoration: InputDecoration(
              labelText: isFinalClue ? 'Finaler Erfolgs-Text' : 'Belohnungs-Text (optional)',
              hintText: 'z.B. Gut gemacht, Agent!',
            ),
            maxLines: 3,
            validator: (v) {
              if (isFinalClue && (v == null || v.isEmpty)) {
                return 'Finaler Text ist für den letzten Hinweis erforderlich.';
              }
              return null;
            },
          ),
          if (!isFinalClue && riddleType != RiddleType.DECISION) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: nextClueCodeController,
              decoration: const InputDecoration(
                labelText: 'Code für nächsten Hinweis (optional)',
                hintText: 'z.B. ADLER3',
              ),
            ),
            CheckboxListTile(
              title: const Text('Nächsten Hinweis automatisch starten'),
              subtitle: const Text('Animiert die Eingabe des nächsten Codes.'),
              value: autoTriggerNextClue,
              onChanged: onAutoTriggerChanged,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGpsRiddleFields(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: latitudeController,
          decoration: const InputDecoration(labelText: 'Breitengrad (Latitude)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => (v == null || v.isEmpty) ? 'Breitengrad erforderlich' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: longitudeController,
          decoration: const InputDecoration(labelText: 'Längengrad (Longitude)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => (v == null || v.isEmpty) ? 'Längengrad erforderlich' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: radiusController,
          decoration: const InputDecoration(labelText: 'Radius in Metern', hintText: 'z.B. 20'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => (v == null || v.isEmpty) ? 'Radius erforderlich' : null,
        ),
        const SizedBox(height: 16),
        Center(
          child: isFetchingLocation
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text('Aktuellen Standort eintragen'),
                  onPressed: onGetCurrentLocation,
                ),
        ),
        _buildGpsBackgroundSection(context),
      ],
    );
  }

  Widget _buildGpsBackgroundSection(BuildContext context) {
    final hasImage = backgroundImagePath != null && backgroundImagePath!.isNotEmpty;
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
                      File(backgroundImagePath!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    label: const Text('Bild entfernen', style: TextStyle(color: Colors.redAccent)),
                    onPressed: onRemoveGpsBackgroundImage,
                  ),
                ],
              ),
            )
          else
            Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Hintergrundbild wählen'),
                onPressed: onPickGpsBackgroundImage,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDecisionRiddleFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Entscheidungs-Optionen & Ziel-Codes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Gib bis zu 4 Optionen an. Für jede Option muss ein gültiger Ziel-Code einer anderen Station eingegeben werden.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        _buildDecisionOptionRow(1, option1Controller, decisionCode1Controller),
        _buildDecisionOptionRow(2, option2Controller, decisionCode2Controller),
        _buildDecisionOptionRow(3, option3Controller, decisionCode3Controller),
        _buildDecisionOptionRow(4, option4Controller, decisionCode4Controller),
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

  Widget _buildTextRiddleFields(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: answerController,
          decoration: const InputDecoration(labelText: 'Korrekte Antwort'),
          validator: (v) => (v == null || v.isEmpty) ? 'Antwort erforderlich' : null,
        ),
        const SizedBox(height: 16),
        if (riddleType == RiddleType.MULTIPLE_CHOICE)
          _buildMultipleChoiceFields(context),
        const SizedBox(height: 16),
        _buildSectionHeader(context, 'Gestaffelte Hilfe (Optional)'),
        TextFormField(controller: hint1Controller, decoration: const InputDecoration(labelText: 'Hilfe nach 2 Fehlversuchen')),
        const SizedBox(height: 8),
        TextFormField(controller: hint2Controller, decoration: const InputDecoration(labelText: 'Hilfe nach 4 Fehlversuchen')),
      ],
    );
  }

  Widget _buildMultipleChoiceFields(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Text('Multiple-Choice Optionen', style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 8),
      TextFormField(controller: option1Controller, decoration: const InputDecoration(labelText: 'Option 1')),
      const SizedBox(height: 8),
      TextFormField(controller: option2Controller, decoration: const InputDecoration(labelText: 'Option 2')),
      const SizedBox(height: 8),
      TextFormField(controller: option3Controller, decoration: const InputDecoration(labelText: 'Option 3')),
      const SizedBox(height: 8),
      TextFormField(controller: option4Controller, decoration: const InputDecoration(labelText: 'Option 4')),
    ]);
  }

  Widget _buildItemDropdown({
    required String label,
    required String hint,
    required String? currentValue,
    required ValueChanged<String?> onChanged,
  }) {
    final items = hunt.items.values.toList()
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
    );
  }
}
// This widget provides a section for editing the riddle details of a clue in a scavenger hunt.