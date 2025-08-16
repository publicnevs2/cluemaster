// lib/features/admin/widgets/clue_content_section.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/clue.dart';

class ClueContentSection extends StatelessWidget {
  final String type;
  final Function(String?) onTypeChanged;
  final TextEditingController contentController;
  final TextEditingController descriptionController;
  final ImageEffect imageEffect;
  final Function(ImageEffect?) onImageEffectChanged;
  final TextEffect textEffect;
  final Function(TextEffect?) onTextEffectChanged;
  final bool isRecording;
  final Function(ImageSource) onPickMedia;
  final VoidCallback onToggleRecording;

  const ClueContentSection({
    super.key,
    required this.type,
    required this.onTypeChanged,
    required this.contentController,
    required this.descriptionController,
    required this.imageEffect,
    required this.onImageEffectChanged,
    required this.textEffect,
    required this.onTextEffectChanged,
    required this.isRecording,
    required this.onPickMedia,
    required this.onToggleRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stations-Inhalt',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: type,
          items: const [
            DropdownMenuItem(value: 'text', child: Text('Text')),
            DropdownMenuItem(value: 'image', child: Text('Bild')),
            DropdownMenuItem(value: 'audio', child: Text('Audio')),
            DropdownMenuItem(value: 'video', child: Text('Video')),
          ],
          onChanged: onTypeChanged,
          decoration: const InputDecoration(labelText: 'Typ des Inhalts'),
        ),
        const SizedBox(height: 8),
        _buildMediaContentField(),
      ],
    );
  }

  Widget _buildMediaContentField() {
    return Column(
      children: [
        if (type == 'text')
          ...[
            TextFormField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Inhalt (Text)'),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Inhalt erforderlich' : null,
            ),
            const SizedBox(height: 8),
            _buildTextEffectField(),
            TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Beschreibung (optional)')),
          ]
        else
          ...[
            TextFormField(
              controller: contentController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Dateipfad ($type)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Datei erforderlich' : null,
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              if (type == 'image' || type == 'video') ...[
                ElevatedButton.icon(icon: const Icon(Icons.photo_library), label: const Text('Galerie'), onPressed: () => onPickMedia(ImageSource.gallery)),
                ElevatedButton.icon(icon: const Icon(Icons.camera_alt), label: const Text('Kamera'), onPressed: () => onPickMedia(ImageSource.camera)),
              ],
              if (type == 'audio')
                ElevatedButton.icon(
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  label: Text(isRecording ? 'Stopp' : 'Aufnehmen'),
                  onPressed: onToggleRecording,
                  style: ElevatedButton.styleFrom(backgroundColor: isRecording ? Colors.red : null),
                ),
            ]),
            const SizedBox(height: 8),
            if (type == 'image')
              _buildImageEffectField(),
            TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Beschreibung (optional)')),
          ]
      ],
    );
  }

  Widget _buildImageEffectField() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: DropdownButtonFormField<ImageEffect>(
        value: imageEffect,
        items: const [
          DropdownMenuItem(value: ImageEffect.NONE, child: Text('Kein Effekt')),
          DropdownMenuItem(value: ImageEffect.PUZZLE, child: Text('Puzzle (9 Teile)')),
          DropdownMenuItem(value: ImageEffect.INVERT_COLORS, child: Text('Farben invertieren')),
          DropdownMenuItem(value: ImageEffect.BLACK_AND_WHITE, child: Text('Schwarz-Weiß')),
        ],
        onChanged: onImageEffectChanged,
        decoration: const InputDecoration(labelText: 'Optionaler Bild-Effekt'),
      ),
    );
  }

  Widget _buildTextEffectField() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: DropdownButtonFormField<TextEffect>(
        value: textEffect,
        items: const [
          DropdownMenuItem(value: TextEffect.NONE, child: Text('Kein Effekt')),
          DropdownMenuItem(value: TextEffect.MORSE_CODE, child: Text('Morsecode')),
          DropdownMenuItem(value: TextEffect.REVERSE, child: Text('Text rückwärts')),
          DropdownMenuItem(value: TextEffect.NO_VOWELS, child: Text('Ohne Vokale')),
          DropdownMenuItem(value: TextEffect.MIRROR_WORDS, child: Text('Wörter spiegeln')),
        ],
        onChanged: onTextEffectChanged,
        decoration: const InputDecoration(labelText: 'Optionaler Text-Effekt'),
      ),
    );
  }
}
