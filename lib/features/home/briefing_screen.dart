import 'dart:io';
import 'package:clue_master/data/models/hunt_progress.dart';
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
    _soundService.playSound(SoundEffect.buttonClick);

    final huntProgress = HuntProgress(
      huntName: widget.hunt.name,
      collectedItemIds: Set<String>.from(widget.hunt.startingItemIds),
    );

    String? firstClueCode;
    if (widget.hunt.clues.isNotEmpty) {
      final upperCaseCodes = widget.hunt.clues.keys.map((k) => k.toUpperCase()).toList();
      final originalCodes = widget.hunt.clues.keys.toList();
      int index = upperCaseCodes.indexOf('STARTX');
      if (index == -1) {
        index = upperCaseCodes.indexOf('START');
      }
      if (index != -1) {
        firstClueCode = originalCodes[index];
      } else {
        firstClueCode = originalCodes.first;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          // HIER WIRD DIE ROUTE BENANNT
          settings: const RouteSettings(name: HomeScreen.routeName),
          builder: (_) => HomeScreen(
                hunt: widget.hunt,
                huntProgress: huntProgress,
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
          if (widget.hunt.briefingImageUrl != null)
            Image.file(
              File(widget.hunt.briefingImageUrl!.replaceFirst('file://', '')),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black,
                  child: const Center(
                      child: Icon(Icons.error_outline,
                          color: Colors.red, size: 50)),
                );
              },
            ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
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