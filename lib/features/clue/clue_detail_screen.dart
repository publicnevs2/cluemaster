// ============================================================
// SECTION: Imports
// ============================================================
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import '../../data/models/clue.dart';
import '../../core/services/clue_service.dart'; // Wichtig für das Speichern des gelösten Status

// ============================================================
// SECTION: ClueDetailScreen Widget
// ============================================================
class ClueDetailScreen extends StatefulWidget {
  final Clue clue;
  const ClueDetailScreen({super.key, required this.clue});

  @override
  State<ClueDetailScreen> createState() => _ClueDetailScreenState();
}

// ============================================================
// SECTION: State-Klasse
// ============================================================
class _ClueDetailScreenState extends State<ClueDetailScreen> {
  // ============================================================
  // SECTION: State & Controller
  // ============================================================
  final _answerController = TextEditingController();
  final _clueService = ClueService();
  String? _errorMessage;

  // Diese Variable steuert, ob der eigentliche Hinweis (die Belohnung) angezeigt wird.
  bool _isHintVisible = false;

  // ============================================================
  // SECTION: Lifecycle
  // ============================================================
  @override
  void initState() {
    super.initState();
    // Wenn der Hinweis kein Rätsel ist ODER bereits gelöst wurde,
    // wird der Inhalt sofort angezeigt.
    if (!widget.clue.isRiddle || widget.clue.solved) {
      _isHintVisible = true;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  // ============================================================
  // SECTION: Logik
  // ============================================================

  /// Prüft die Antwort des Spielers.
  void _checkAnswer({String? userAnswer}) async {
    final correctAnswer = widget.clue.answer?.trim().toLowerCase();
    // Nimmt entweder die Antwort vom Button (userAnswer) oder aus dem Textfeld.
    final providedAnswer = (userAnswer ?? _answerController.text).trim().toLowerCase();

    if (correctAnswer == providedAnswer) {
      // Antwort ist richtig!
      setState(() {
        _isHintVisible = true; // Macht den Hinweis-Container sichtbar.
        _errorMessage = null;
        widget.clue.solved = true; // Markiert den Hinweis als gelöst.
      });

      // Speichere den neuen "solved"-Status in der JSON-Datei.
      final allClues = await _clueService.loadClues();
      allClues[widget.clue.code] = widget.clue;
      await _clueService.saveClues(allClues);

      // Der 'mounted'-Check ist eine Sicherheitsmaßnahme in async-Methoden.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Richtig! Gut gemacht!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Antwort ist falsch.
      setState(() {
        _errorMessage = 'Leider falsch. Versuch es nochmal!';
      });
    }
  }

  // ============================================================
  // SECTION: UI-Aufbau (build-Methode)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hinweis')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // ANZEIGE-LOGIK:
                    // Wenn der Hinweis sichtbar ist, zeige den Inhalt.
                    // Sonst zeige das Rätsel.
                    if (_isHintVisible)
                      _buildContentWidget() // Der eigentliche Hinweis (Belohnung)
                    else
                      _buildRiddleWidget(), // Das Rätsel (Tor)
                  ],
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

  // ============================================================
  // SECTION: UI-Builder für die Widgets
  // ============================================================

  /// Baut das Widget für das RÄTSEL.
  Widget _buildRiddleWidget() {
    return Column(
      children: [
        // Zeigt die Frage an.
        Text(
          widget.clue.question!,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Entscheidet, ob Multiple-Choice-Buttons oder ein Textfeld angezeigt werden.
        if (widget.clue.isMultipleChoice)
          // Baut die Buttons für Multiple Choice.
          ...widget.clue.options!.map((option) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                onPressed: () => _checkAnswer(userAnswer: option),
                child: Text(option, style: const TextStyle(fontSize: 16)),
              ),
            );
          }).toList()
        else
          // Baut das Textfeld für die freie Eingabe.
          TextField(
            controller: _answerController,
            decoration: InputDecoration(
              hintText: 'Deine Antwort hier...',
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
        
        // Zeigt eine Fehlermeldung an, wenn die Antwort falsch war.
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
      ],
    );
  }

  /// Baut das Widget für den HINWEIS-INHALT (die Belohnung).
  Widget _buildContentWidget() {
    // Diese Logik entscheidet, ob Text, Bild, Audio etc. angezeigt wird.
    switch (widget.clue.type) {
      case 'text':
        return Text(widget.clue.content, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
      case 'image':
        Widget imageWidget;
        String path = widget.clue.content;
        if (path.startsWith('file://')) {
          path = path.replaceFirst('file://', '');
          imageWidget = Image.file(File(path));
        } else {
          imageWidget = Image.asset(path);
        }
        return Column(
          children: [
            imageWidget,
            if (widget.clue.description != null) ...[
              const SizedBox(height: 12),
              Text(widget.clue.description!, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
            ],
          ],
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


// ============================================================
// SECTION: Unveränderte Hilfs-Widgets (Audio/Video Player)
// ============================================================
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
    return Column(
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
    return Column(
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
    );
  }
}
