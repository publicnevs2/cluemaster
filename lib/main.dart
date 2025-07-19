// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';

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
      title: 'ClueMaster',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      navigatorObservers: [routeObserver],  // ← hier aktivieren
    );
  }
}
