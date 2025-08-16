// lib/features/shared/widgets/info_item_widgets.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MorseAlphabetWidget extends StatefulWidget {
  const MorseAlphabetWidget({super.key});

  @override
  State<MorseAlphabetWidget> createState() => _MorseAlphabetWidgetState();
}

class _MorseAlphabetWidgetState extends State<MorseAlphabetWidget> {
  final _textController = TextEditingController();
  final _dotPlayer = AudioPlayer();
  final _dashPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _translatedMorse = '';

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
  void initState() {
    super.initState();
    _dotPlayer.setAsset('assets/audio/dot.mp3');
    _dashPlayer.setAsset('assets/audio/dash.mp3');
  }

  @override
  void dispose() {
    _textController.dispose();
    _dotPlayer.dispose();
    _dashPlayer.dispose();
    super.dispose();
  }

  String _toMorseCode(String input) {
    return input
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9 ]'), '') // Nur Buchstaben, Zahlen, Leerzeichen
        .split('')
        .map((char) => _morseCodeMap[char] ?? '')
        .join(' ');
  }

  Future<void> _translateAndPlay() async {
    if (_isPlaying || _textController.text.isEmpty) return;
    
    final morseString = _toMorseCode(_textController.text);
    setState(() {
      _isPlaying = true;
      _translatedMorse = morseString;
    });

    for (final char in morseString.split('')) {
      if (!mounted) break;
      switch (char) {
        case '.':
          await _dotPlayer.seek(Duration.zero);
          await _dotPlayer.play();
          await Future.delayed(const Duration(milliseconds: 200));
          break;
        case '-':
          await _dashPlayer.seek(Duration.zero);
          await _dashPlayer.play();
          await Future.delayed(const Duration(milliseconds: 400));
          break;
        case ' ':
          await Future.delayed(const Duration(milliseconds: 200));
          break;
      }
    }
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

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
                'Morse-Code Übersetzer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Text eingeben',
              hintText: 'z.B. SOS',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isPlaying ? null : _translateAndPlay,
            icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
            label: const Text('Übersetzen & Abspielen'),
          ),
          if (_translatedMorse.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Morse-Code:',
              style: TextStyle(color: Colors.amber[200]),
            ),
            const SizedBox(height: 8),
            Text(
              _translatedMorse,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'SpecialElite',
                letterSpacing: 2,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
