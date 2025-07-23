// lib/main.dart

import 'package:clue_master/features/home/splash_screen.dart';
import 'package:flutter/material.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(const ClueMasterApp());
}

class ClueMasterApp extends StatelessWidget {
  const ClueMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MissionControl by Sven Kompe',
      theme: ThemeData(
        fontFamily: 'SpecialElite',
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF212121),
        cardColor: const Color(0xFF303030),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF303030),
          elevation: 4,
          centerTitle: true,
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Colors.white),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF424242),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
      home: const SplashScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}
