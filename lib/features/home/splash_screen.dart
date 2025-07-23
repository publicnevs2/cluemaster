// lib/features/home/splash_screen.dart

import 'package:flutter/material.dart';
import 'hunt_selection_screen.dart';
import '../../core/services/sound_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _soundService.playSound(SoundEffect.appStart);
  }

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/20211205_FamilienfotomitdemBärtigen.jpg'),
            fit: BoxFit.cover,
            // Korrigierte Version für den Filter
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(102), // (0-255, 102 ist ca. 40%)
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(flex: 2),
              const Text(
                'Papa Svens\nMissionControl',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                child: const Text('Mission starten!'),
                onPressed: () {
                  _soundService.playSound(SoundEffect.buttonClick);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HuntSelectionScreen()),
                  );
                },
              ),
              const Spacer(flex: 1),
              const Text(
                '(C) Sven Kompe, 2025',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}