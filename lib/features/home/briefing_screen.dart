import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/hunt.dart';
import 'home_screen.dart';

class BriefingScreen extends StatefulWidget {
  final Hunt hunt;

  const BriefingScreen({super.key, required this.hunt});

  @override
  State<BriefingScreen> createState() => _BriefingScreenState();
}

class _BriefingScreenState extends State<BriefingScreen> {
  final SoundService _soundService = SoundService();

  // FINALE UND KORRIGIERTE LOGIK
  void _acceptMission() {
    Vibration.vibrate(duration: 50);
    _soundService.playSound(SoundEffect.buttonClick);

    String? firstClueCode; // Der Start-Code, kann null sein.

    if (widget.hunt.clues.isNotEmpty) {
      // Wir erstellen eine Liste der Codes in Großbuchstaben für den Vergleich.
      final upperCaseCodes = widget.hunt.clues.keys.map((k) => k.toUpperCase()).toList();
      final originalCodes = widget.hunt.clues.keys.toList();

      // Priorität 1: Suche nach "STARTX"
      int index = upperCaseCodes.indexOf('STARTX');
      
      // Priorität 2: Wenn "STARTX" nicht gefunden wurde, suche nach "START"
      if (index == -1) {
        index = upperCaseCodes.indexOf('START');
      }

      // Wenn einer der beiden Start-Codes gefunden wurde, nimm den originalen Code.
      // Ansonsten nimm als Fallback den allerersten Code in der Liste.
      if (index != -1) {
        firstClueCode = originalCodes[index];
      } else {
        firstClueCode = originalCodes.first;
      }
    }

    // Wir übergeben den gefundenen Code sicher an den HomeScreen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => HomeScreen(
                hunt: widget.hunt,
                codeToAnimate: firstClueCode,
              )),
    );
  }

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Hintergrundbild, falls vorhanden
          if (widget.hunt.briefingImageUrl != null)
            Image.file(
              File(widget.hunt.briefingImageUrl!.replaceFirst('file://', '')),
              fit: BoxFit.cover,
              // Fehler-Widget, falls das Bild nicht geladen werden kann
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black,
                  child: const Center(
                      child: Icon(Icons.error_outline,
                          color: Colors.red, size: 50)),
                );
              },
            ),

          // Schwarzer Overlay für bessere Lesbarkeit des Textes
          Container(
            color: Colors.black.withOpacity(0.7),
          ),

          // Inhalt (Text und Button)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'Missions-Briefing',
                    style: TextStyle(
                      fontFamily: 'SpecialElite',
                      fontSize: 28,
                      color: Colors.amber.shade200,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Divider(color: Colors.white30, height: 32),
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: Text(
                        widget.hunt.briefingText ?? 'Kein Briefing verfügbar.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(
                          fontSize: 18, fontFamily: 'SpecialElite'),
                    ),
                    onPressed: _acceptMission,
                    child: const Text('MISSION ANNEHMEN'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}