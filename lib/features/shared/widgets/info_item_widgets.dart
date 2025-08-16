// lib/features/shared/widgets/info_item_widgets.dart

import 'package:flutter/material.dart';

/// Ein Widget, das eine Tabelle mit dem Morse-Alphabet anzeigt.
class MorseAlphabetWidget extends StatelessWidget {
  const MorseAlphabetWidget({super.key});

  static const Map<String, String> _morseCodeMap = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
    'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
    'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
    'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
    'Y': '-.--', 'Z': '--..', '0': '-----', '1': '.----', '2': '..---',
    '3': '...--', '4': '....-', '5': '.....', '6': '-....', '7': '--...',
    '8': '---..', '9': '----.'
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.translate, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Internationales Morse-Alphabet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          // Wrap sorgt für einen automatischen Zeilenumbruch, wenn der Platz eng wird
          Wrap(
            spacing: 16.0, // Horizontaler Abstand
            runSpacing: 8.0, // Vertikaler Abstand
            alignment: WrapAlignment.center,
            children: _morseCodeMap.entries.map((entry) {
              return Chip(
                backgroundColor: Colors.grey[800],
                label: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'SpecialElite',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
