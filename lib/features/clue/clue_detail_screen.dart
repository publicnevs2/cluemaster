// ============================================================
// SECTION: Imports
// ============================================================
import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/clue.dart';

// ============================================================
// SECTION: ClueDetailScreen Widget
// ============================================================
class ClueDetailScreen extends StatelessWidget {
  final Clue clue;
  const ClueDetailScreen({super.key, required this.clue});

// ============================================================
// SECTION: Helper-Widget-Erstellung
// ============================================================
  Widget _buildContent() {
    if (clue.type == 'text') {
      // Text-Hinweis
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          clue.content,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      // Bild-Hinweis: Asset vs. File
      Widget imageWidget;
      String path = clue.content;
      if (path.startsWith('file://')) {
        // lokaler File-Pfad aus Galerie
        path = path.replaceFirst('file://', '');
        imageWidget = Image.file(File(path));
      } else {
        // vordefiniertes Asset
        imageWidget = Image.asset(path);
      }

      // Beschreibung anzeigen
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            imageWidget,
            if (clue.description != null) ...[
              const SizedBox(height: 12),
              Text(
                clue.description!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }
  }

// ============================================================
// SECTION: Build-Method (UI-Aufbau)
// ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hinweis')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: _buildContent())),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                '(C) Sven Kompe 2025',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
