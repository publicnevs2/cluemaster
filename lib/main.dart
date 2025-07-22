// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import 'features/home/hunt_selection_screen.dart'; // NEU: Importiere den neuen Auswahl-Bildschirm.

// ============================================================
// SECTION: Route Observer
// ============================================================
/// Beobachtet, wenn man zwischen Screens navigiert
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// ============================================================
// SECTION: App-Einstieg
// ============================================================
void main() {
  runApp(const ClueMasterApp());
}

class ClueMasterApp extends StatelessWidget {
  const ClueMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClueMaster by Sven Kompe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // KORREKTUR: Der Startbildschirm der App ist jetzt der HuntSelectionScreen.
      home: const HuntSelectionScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}
