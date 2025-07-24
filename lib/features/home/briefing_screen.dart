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

  void _acceptMission() {
    Vibration.vibrate(duration: 50);
    // Hier könnten wir einen speziellen "bestätigt"-Sound abspielen,
    // für den Moment nutzen wir den Standard-Klick.
    _soundService.playSound(SoundEffect.buttonClick);

    // Ersetzt den Briefing-Screen durch den Home-Screen, damit der Spieler
    // mit dem Zurück-Button nicht wieder zum Briefing kommt.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(hunt: widget.hunt)),
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
                  child: const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 50)),
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
                      textStyle: const TextStyle(fontSize: 18, fontFamily: 'SpecialElite'),
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
