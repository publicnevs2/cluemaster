import 'dart:io';
import 'package:clue_master/core/services/clue_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import '../../data/models/clue.dart';

// Wir wandeln den Bildschirm in ein StatefulWidget um, damit er sich den Zustand des Rätsels merken kann.
class ClueDetailScreen extends StatefulWidget {
  final Clue clue;
  const ClueDetailScreen({super.key, required this.clue});

  @override
  State<ClueDetailScreen> createState() => _ClueDetailScreenState();
}

class _ClueDetailScreenState extends State<ClueDetailScreen> {
  // Zustandsvariablen für das Rätsel
  final _answerController = TextEditingController();
  bool _isRiddleSolved = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Wenn der Hinweis kein Rätsel ist, gilt er sofort als gelöst.
    if (!widget.clue.isRiddle) {
      _isRiddleSolved = true;
    }
  }
  
  void _checkAnswer() {
    final correctAnswer = widget.clue.answer?.trim().toLowerCase();
    final userAnswer = _answerController.text.trim().toLowerCase();

    if (correctAnswer == userAnswer) {
      setState(() {
        _isRiddleSolved = true;
        _errorMessage = null;
        widget.clue.solved = true; // Markiere den Hinweis als endgültig gelöst
        // Optional: Speichere den gelösten Status sofort.
        // Dies erfordert Zugriff auf den ClueService.
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Richtig! Gut gemacht!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Leider falsch. Versuch es nochmal!';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hinweis')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Der eigentliche Hinweis-Inhalt wird immer angezeigt.
                      _buildContent(),
                      
                      // Der RÄTSEL-TEIL wird nur angezeigt, wenn es ein Rätsel ist.
                      if (widget.clue.isRiddle)
                        _buildRiddleSection(),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text('(C) Sven Kompe 2025', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  // Diese Methode baut den Rätsel-Teil der UI
  Widget _buildRiddleSection() {
    if (_isRiddleSolved) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Rätsel gelöst!', style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Divider(height: 30),
          Text(
            widget.clue.question!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _answerController,
            decoration: InputDecoration(
              hintText: 'Deine Antwort',
              errorText: _errorMessage,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _checkAnswer,
            child: const Text('Antwort prüfen'),
          )
        ],
      ),
    );
  }

  // Diese Methode baut den Hinweis-Inhalt (Bild, Video etc.)
  Widget _buildContent() {
    switch (widget.clue.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(widget.clue.content, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
        );
      case 'image':
        Widget imageWidget;
        String path = widget.clue.content;
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
              if (widget.clue.description != null) ...[
                const SizedBox(height: 12),
                Text(widget.clue.description!, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              ],
            ],
          ),
        );
      case 'audio':
        return AudioPlayerWidget(path: widget.clue.content, description: widget.clue.description);
      case 'video':
        return VideoPlayerWidget(path: widget.clue.content, description: widget.clue.description);
      default:
        return const Center(child: Text('Unbekannter Hinweistyp'));
    }
  }
}


// Die Widgets für Audio und Video bleiben unverändert.
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
        await _player.setAsset(widget.path);
      }
    } catch (e) {
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

class VideoPlayerWidget extends StatefulWidget {
  final String path;
  final String? description;
  const VideoPlayerWidget({super.key, required this.path, this.description});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    final videoFile = File(widget.path.replaceFirst('file://', ''));
    _controller = VideoPlayerController.file(videoFile);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(false); 
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          const SizedBox(height: 24),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (_controller.value.position == _controller.value.duration) {
                  _controller.seekTo(Duration.zero);
                  _controller.play();
                } else if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
            child: Icon(
              _controller.value.position == _controller.value.duration
                  ? Icons.replay
                  : _controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.description != null)
            Text(
              widget.description!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }
}
