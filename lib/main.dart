// lib/main.dart

import 'package:clue_master/features/home/splash_screen.dart';
import 'package:flutter/material.dart';

// Diese Variable MUSS hier global bleiben, damit alle Screens darauf zugreifen können.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
      // Hier wird der neue SplashScreen als Startpunkt der App festgelegt
      home: const SplashScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}