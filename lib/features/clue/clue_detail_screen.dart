// ============================================================
// SECTION: Imports
// ============================================================
import 'dart:io';
import 'package:clue_master/data/models/hunt.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import '../../data/models/clue.dart';
import '../../core/services/clue_service.dart';

// ============================================================
// SECTION: ClueDetailScreen Widget
// ============================================================
class ClueDetailScreen extends StatefulWidget {
  // NEU: Der Screen benötigt jetzt die Information über die gesamte Jagd.
  final Hunt hunt;
  final Clue clue;

  const ClueDetailScreen({super.key, required this.hunt, required this.clue});

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
  final _scrollController = ScrollController();

  bool _isSolved = false;
  int _wrongAttempts = 0;
  String? _errorMessage;

  // ============================================================
  // SECTION: Lifecycle
  // ============================================================
  @override
  void initState() {
    super.initState();
    if (widget.clue.solved) {
      _isSolved = true;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // SECTION: Logik
  // ============================================================

  /// Prüft die Antwort und speichert den Fortschritt korrekt.
  void _checkAnswer({String? userAnswer}) async {
    final correctAnswer = widget.clue.answer?.trim().toLowerCase();
    final providedAnswer = (userAnswer ?? _answerController.text).trim().toLowerCase();

    if (correctAnswer == providedAnswer) {
      // ANTWORT RICHTIG
      setState(() {
        _isSolved = true;
        widget.clue.solved = true;
      });

      // ============================================================
      // KORREKTUR: Die Speicherlogik wurde repariert.
      // ============================================================
      // 1. Lade die aktuelle Liste aller Jagden.
      final allHunts = await _clueService.loadHunts();
      // 2. Finde den Index der Jagd, die wir gerade spielen.
      final huntIndex = allHunts.indexWhere((h) => h.name == widget.hunt.name);

      if (huntIndex != -1) {
        // 3. Aktualisiere den spezifischen Hinweis in der korrekten Jagd.
        allHunts[huntIndex].clues[widget.clue.code] = widget.clue;
        // 4. Speichere die gesamte aktualisierte Liste aller Jagden.
        await _clueService.saveHunts(allHunts);
      }
      // ============================================================

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Richtig! Belohnung freigeschaltet!'), backgroundColor: Colors.green),
      );
    } else {
      // ANTWORT FALSCH
      setState(() {
        _wrongAttempts++;
        _errorMessage = 'Leider falsch. Versuch es nochmal!';
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // ============================================================
  // SECTION: UI-Aufbau (build-Methode)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Station')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildMediaWidget(
                      type: widget.clue.type,
                      content: widget.clue.content,
                      description: widget.clue.description,
                    ),
                    const SizedBox(height: 16),
                    if (widget.clue.isRiddle) ...[
                      const Divider(height: 24, thickness: 1),
                      if (_isSolved)
                        _buildRewardWidget()
                      else
                        _buildRiddleWidget(),
                    ]
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

  // ... (Der Rest der Datei, alle _build... Methoden und die Player-Widgets, bleiben unverändert)
  Widget _buildRiddleWidget() {
    return Column(
      children: [
        Text(
          widget.clue.question!,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        widget.clue.isMultipleChoice
            ? _buildMultipleChoiceOptions()
            : _buildTextAnswerField(),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
          ),
        if (_wrongAttempts >= 3 && widget.clue.hint1 != null)
          _buildHintCard(1, widget.clue.hint1!),
        if (_wrongAttempts >= 6 && widget.clue.hint2 != null)
          _buildHintCard(2, widget.clue.hint2!),
      ],
    );
  }

  Widget _buildRewardWidget() {
    return Card(
      color: Colors.green.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Rätsel gelöst!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 16),
            Text(
              widget.clue.rewardText ?? 'Sehr gut gemacht!',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceOptions() {
    return Column(
      children: widget.clue.options!.map((option) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ElevatedButton(
            onPressed: () => _checkAnswer(userAnswer: option),
            child: Text(option, style: const TextStyle(fontSize: 16)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextAnswerField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _answerController,
            decoration: const InputDecoration(hintText: 'Deine Antwort...', border: OutlineInputBorder()),
            onSubmitted: (_) => _checkAnswer(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          icon: const Icon(Icons.send),
          onPressed: () => _checkAnswer(),
        ),
      ],
    );
  }
  
  Widget _buildHintCard(int level, String hintText) {
    return Card(
      margin: const EdgeInsets.only(top: 24),
      color: Colors.amber.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(child: Text("Hilfe $level: $hintText")),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaWidget({required String type, required String content, String? description}) {
    Widget mediaWidget;
    switch (type) {
      case 'text':
        mediaWidget = Text(content, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
        break;
      case 'image':
        mediaWidget = content.startsWith('file://')
            ? Image.file(File(content.replaceFirst('file://', '')))
            : Image.asset(content);
        break;
      case 'audio':
        return AudioPlayerWidget(path: content, description: description);
      case 'video':
        return VideoPlayerWidget(path: content, description: description);
      default:
        mediaWidget = const Center(child: Text('Unbekannter Inhaltstyp'));
    }
    
    return Column(
      children: [
        mediaWidget,
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

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
        const Text("Audio-Hinweis abspielen", style: TextStyle(fontSize: 16)),
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
      if (mounted) {
        setState(() {});
      }
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
        Center(
          child: FutureBuilder(
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
        ),
        const SizedBox(height: 24),
        FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_controller.value.position >= _controller.value.duration) {
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
            _controller.value.position >= _controller.value.duration
                ? Icons.replay
                : _controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
          ),
        ),
      ],
    );
  }
}
