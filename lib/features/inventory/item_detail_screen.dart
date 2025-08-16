// lib/features/inventory/item_detail_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/item.dart';
import '../../data/models/clue.dart';
import '../shared/media_widgets.dart';
import '../shared/widgets/flashlight_widget.dart'; // WICHTIGER IMPORT

class ItemDetailScreen extends StatelessWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sektion 1: Der Hauptinhalt des Items (Bild, Video, etc.)
            Center(
              child: _buildMediaWidgetForItem(item),
            ),
            const SizedBox(height: 24),

            // Sektion 2: Die Beschreibung
            if (item.description != null && item.description!.isNotEmpty) ...[
              _buildSectionHeader(context, 'Beschreibung'),
              const SizedBox(height: 8),
              Text(
                item.description!,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 24),
            ],

            // Sektion 3: Der "Untersuchen"-Text für versteckte Hinweise
            if (item.examineText != null && item.examineText!.isNotEmpty) ...[
              _buildSectionHeader(context, 'Bei genauerer Betrachtung...'),
              const SizedBox(height: 8),
              Card(
                color: Colors.amber.withOpacity(0.15),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.examineText!,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Baut eine formatierte Überschrift für eine Sektion.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.amber,
            fontFamily: 'SpecialElite',
          ),
    );
  }

  /// Diese Methode ist der Kern der neuen Logik. Sie entscheidet,
  /// welches Widget für das jeweilige Item angezeigt wird.
  Widget _buildMediaWidgetForItem(Item item) {
    // PRÜFUNG 1: Ist es ein interaktives Werkzeug?
    if (item.itemCategory == ItemCategory.INTERACTIVE) {
      // Prüfe die Widget-Kennung (den "content"-String)
      switch (item.content) {
        case 'taschenlampe':
          return const FlashlightWidget();
        // Hier können später weitere Widgets wie 'morse_translator' etc. hinzukommen
        default:
          return Text('Unbekanntes interaktives Widget: ${item.content}');
      }
    }

    // PRÜFUNG 2: Wenn nicht interaktiv, behandle es wie einen normalen Hinweis
    String clueTypeString = item.contentType.toString().split('.').last;

    // Wir erstellen einen "Dummy"-Hinweis, um unsere bestehende Logik wiederzuverwenden
    final dummyClue = Clue(
      code: 'dummy',
      type: clueTypeString,
      content: item.content,
      imageEffect: ImageEffect.NONE,
      textEffect: TextEffect.NONE,
    );

    return buildMediaWidgetForClue(clue: dummyClue);
  }
}
