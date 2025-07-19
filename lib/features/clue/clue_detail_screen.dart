import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/clue.dart';

class ClueDetailScreen extends StatelessWidget {
  final Clue clue;
  const ClueDetailScreen({super.key, required this.clue});

  Widget _buildContent() {
    switch (clue.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(clue.content, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
        );
      case 'image':
        Widget imageWidget;
        String path = clue.content;
        if (path.startsWith('file://')) {
          path = path.replaceFirst('file://', '');
          imageWidget = Image.file(File(path));
        } else {
          imageWidget = Image.asset(path);
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              imageWidget,
              if (clue.description != null) ...[
                const SizedBox(height: 12),
                Text(clue.description!, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              ],
            ],
          ),
        );
      // NEUER CASE für Audio
      case 'audio':
        return AudioPlayerWidget(path: clue.content, description: clue.description);
      default:
        return const Center(child: Text('Unbekannter Hinweistyp'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hinweis')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(child: SingleChildScrollView(child: _buildContent()))),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text('(C) Sven Kompe 2025', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

// NEUES WIDGET für den Audio-Player
class AudioPlayerWidget extends StatefulWidget {
  final String path;
  final String? description;
  const AudioPlayerWidget({super.key, required this.path, this.description});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.path.startsWith('file://')) {
        final filePath = widget.path.replaceFirst('file://', '');
        await _player.setFilePath(filePath);
      } else {
        // Für eventuelle vordefinierte Audio-Assets
        await _player.setAsset(widget.path);
      }
    } catch (e) {
      // Fehlerbehandlung
      print("Fehler beim Laden der Audio-Datei: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.audiotrack, size: 120, color: Colors.blueAccent),
          const SizedBox(height: 24),
          if (widget.description != null) ...[
            Text(widget.description!, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 24),
          ],
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;

              if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                return const CircularProgressIndicator();
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_circle_fill, size: 80),
                  color: Colors.blue,
                  onPressed: _player.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause_circle_filled, size: 80),
                  color: Colors.blue,
                  onPressed: _player.pause,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.replay_circle_filled, size: 80),
                  color: Colors.blue,
                  onPressed: () => _player.seek(Duration.zero),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          const Text("Hinweis abspielen", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}