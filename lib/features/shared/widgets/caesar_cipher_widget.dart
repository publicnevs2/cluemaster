// lib/features/shared/widgets/caesar_cipher_widget.dart

import 'package:flutter/material.dart';

class CaesarCipherWidget extends StatefulWidget {
  const CaesarCipherWidget({super.key});

  @override
  State<CaesarCipherWidget> createState() => _CaesarCipherWidgetState();
}

class _CaesarCipherWidgetState extends State<CaesarCipherWidget> {
  final _textController = TextEditingController();
  int _shift = 3; // Standard-Verschiebung
  String _outputText = '';
  bool _isEncrypting = true; // Modus: Verschlüsseln oder Entschlüsseln

  final String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  void _updateOutput() {
    final inputText = _textController.text.toUpperCase();
    String result = '';
    final shift = _isEncrypting ? _shift : -_shift;

    for (int i = 0; i < inputText.length; i++) {
      final char = inputText[i];
      final index = _alphabet.indexOf(char);
      if (index != -1) {
        final newIndex = (index + shift) % 26;
        result += _alphabet[newIndex];
      } else {
        result += char; // Zeichen, die nicht im Alphabet sind, bleiben unverändert
      }
    }
    setState(() {
      _outputText = result;
    });
  }

  void _changeShift(int delta) {
    setState(() {
      _shift = (_shift + delta) % 26;
      if (_shift < 0) _shift += 26;
      _updateOutput();
    });
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateOutput);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
              Icon(Icons.sync_lock_outlined, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Caesar-Verschlüsselung',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildShiftSelector(),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: _isEncrypting ? 'Klartext eingeben' : 'Geheimtext eingeben',
              hintText: '...',
            ),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.arrow_downward_rounded),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _outputText.isEmpty ? '...' : _outputText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftSelector() {
    return Column(
      children: [
        Text('Verschiebung: $_shift', style: const TextStyle(fontSize: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => _changeShift(-1),
            ),
            Expanded(
              child: Slider(
                value: _shift.toDouble(),
                min: 0,
                max: 25,
                divisions: 25,
                label: _shift.toString(),
                onChanged: (value) {
                  setState(() {
                    _shift = value.toInt();
                    _updateOutput();
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _changeShift(1),
            ),
          ],
        ),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Verschlüsseln')),
            ButtonSegment(value: false, label: Text('Entschlüsseln')),
          ],
          selected: {_isEncrypting},
          onSelectionChanged: (newSelection) {
            setState(() {
              _isEncrypting = newSelection.first;
              _updateOutput();
            });
          },
        ),
      ],
    );
  }
}
