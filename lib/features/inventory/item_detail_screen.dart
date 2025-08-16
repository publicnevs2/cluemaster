// lib/features/inventory/item_detail_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/item.dart';
import '../../data/models/clue.dart';
import '../shared/media_widgets.dart';
import '../shared/widgets/flashlight_widget.dart';
import '../shared/widgets/info_item_widgets.dart';
import '../shared/widgets/caesar_cipher_widget.dart'; // NEUER IMPORT
//
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
            Center(
              child: _buildMediaWidgetForItem(item),
            ),
            const SizedBox(height: 24),
            if (item.description != null && item.description!.isNotEmpty) ...[
              _buildSectionHeader(context, 'Beschreibung'),
              const SizedBox(height: 8),
              Text(
                item.description!,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 24),
            ],
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.amber,
            fontFamily: 'SpecialElite',
          ),
    );
  }

  Widget _buildMediaWidgetForItem(Item item) {
    switch (item.itemCategory) {
      case ItemCategory.INTERACTIVE:
        switch (item.content) {
          case 'taschenlampe':
            return const FlashlightWidget();
          // ============================================================
          // NEU: Erkennt die Caesar-Scheibe
          // ============================================================
          case 'caesar_cipher':
            return const CaesarCipherWidget();
          default:
            return Text('Unbekanntes interaktives Widget: ${item.content}');
        }
      case ItemCategory.INFO:
        switch (item.id) {
          case 'morse_alphabet':
            return const MorseAlphabetWidget();
          default:
            return Text('Unbekanntes Info-Item: ${item.id}');
        }
      case ItemCategory.REGULAR:
      default:
        String clueTypeString = item.contentType.toString().split('.').last;
        final dummyClue = Clue(
          code: 'dummy',
          type: clueTypeString,
          content: item.content,
        );
        return buildMediaWidgetForClue(clue: dummyClue);
    }
  }
}
