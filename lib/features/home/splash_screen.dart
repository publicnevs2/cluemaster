// lib/features/home/splash_screen.dart

import 'package:flutter/material.dart';
import 'hunt_selection_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Hintergrundbild mit leichter Abdunkelung für bessere Lesbarkeit
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/20211205_FamilienfotomitdemBärtigen.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(flex: 2),
              // Der neue App-Titel
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
              // Der Start-Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                child: const Text('Mission starten!'),
                onPressed: () {
                  // Navigation zur Schnitzeljagd-Auswahl
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HuntSelectionScreen()),
                  );
                },
              ),
              const Spacer(flex: 1),
              // Dein Copyright
              const Text(
                '(C) Sven Kompe, 2025',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20), // Etwas Abstand zum unteren Rand
            ],
          ),
        ),
      ),
    );
  }
}