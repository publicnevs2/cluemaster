import 'dart:io';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/clue.dart';

class MissionSuccessScreen extends StatefulWidget {
  final Clue finalClue;

  const MissionSuccessScreen({super.key, required this.finalClue});

  @override
  State<MissionSuccessScreen> createState() => _MissionSuccessScreenState();
}

class _MissionSuccessScreenState extends State<MissionSuccessScreen> {
  late ConfettiController _confettiController;
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _playSoundSequence();
    _confettiController.play();
  }

  void _playSoundSequence() {
    // Spielt die Fanfare (success.mp3) ab.
    _soundService.playSound(SoundEffect.success);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _soundService.dispose();
    super.dispose();
  }

  void _exitToMainMenu() {
    // Spielt den App-Start-Sound ab, bevor zum Hauptmenü zurückgekehrt wird.
    _soundService.playSound(SoundEffect.appStart);
    // Navigiert ganz an den Anfang der App (zum HuntSelectionScreen).
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // schießt nach unten
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.05,
              shouldLoop: false,
              colors: const [
                Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'MISSION ERFÜLLT!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SpecialElite',
                      fontSize: 36,
                      color: Colors.amber.shade200,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Zeigt die finale Botschaft an
                  _buildMediaWidget(
                    type: widget.finalClue.type,
                    content: widget.finalClue.content,
                    description: widget.finalClue.rewardText, // Der Erfolgs-Text als Beschreibung
                  ),
                  const Spacer(flex: 3),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _exitToMainMenu,
                    child: const Text('Zurück zur Auswahl'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Diese Widgets sind Kopien aus dem clue_detail_screen, um die finale Botschaft anzuzeigen.
Widget _buildMediaWidget({required String type, required String content, String? description}) {
  Widget mediaWidget;
  switch (type) {
    case 'text':
      mediaWidget = Text(content, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
      break;
    case 'image':
      mediaWidget = content.startsWith('file://') ? Image.file(File(content.replaceFirst('file://', ''))) : Image.asset(content);
      break;
    case 'audio':
      return _AudioPlayerWidget(path: content, description: description);
    case 'video':
      return _VideoPlayerWidget(path: content, description: description);
    default:
      mediaWidget = const Center(child: Text('Unbekannter Inhaltstyp'));
  }
  return Column(children: [ mediaWidget, if (description != null && description.isNotEmpty) ...[ const SizedBox(height: 12), Text(description, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic), textAlign: TextAlign.center), ], ],);
}

class _AudioPlayerWidget extends StatefulWidget {
  final String path;
  final String? description;
  const _AudioPlayerWidget({required this.path, this.description});
  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  final _player = AudioPlayer();
  @override
  void initState() { super.initState(); _initPlayer(); }
  Future<void> _initPlayer() async { try { if (widget.path.startsWith('file://')) { await _player.setFilePath(widget.path.replaceFirst('file://', '')); } else { await _player.setAsset(widget.path); } } catch (e) { debugPrint("Fehler beim Laden der Audio-Datei: $e"); } }
  @override
  void dispose() { _player.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return Column(mainAxisAlignment: MainAxisAlignment.center, children: [ const Icon(Icons.audiotrack, size: 120, color: Colors.amber), const SizedBox(height: 24), StreamBuilder<PlayerState>(stream: _player.playerStateStream, builder: (context, snapshot) { final playerState = snapshot.data; final processingState = playerState?.processingState; final playing = playerState?.playing; if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) { return const CircularProgressIndicator(); } else if (playing != true) { return IconButton(icon: const Icon(Icons.play_circle_fill, size: 80), color: Colors.amber, onPressed: _player.play); } else if (processingState != ProcessingState.completed) { return IconButton(icon: const Icon(Icons.pause_circle_filled, size: 80), color: Colors.amber, onPressed: _player.pause); } else { return IconButton(icon: const Icon(Icons.replay_circle_filled, size: 80), color: Colors.amber, onPressed: () => _player.seek(Duration.zero)); } }), const SizedBox(height: 8), const Text("Finale Audio-Botschaft"), ], ); }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String path;
  final String? description;
  const _VideoPlayerWidget({required this.path, this.description});
  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() { super.initState(); final videoFile = File(widget.path.replaceFirst('file://', '')); _controller = VideoPlayerController.file(videoFile); _initializeVideoPlayerFuture = _controller.initialize(); _controller.setLooping(false); _controller.addListener(() { if (mounted) { setState(() {}); } }); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return Column(mainAxisAlignment: MainAxisAlignment.center, children: [ Center(child: FutureBuilder(future: _initializeVideoPlayerFuture, builder: (context, snapshot) { if (snapshot.connectionState == ConnectionState.done) { return Container(constraints: const BoxConstraints(maxHeight: 400), child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))); } else { return const Center(child: CircularProgressIndicator()); } })), const SizedBox(height: 24), FloatingActionButton(backgroundColor: Colors.amber, foregroundColor: Colors.black, onPressed: () { setState(() { if (_controller.value.position >= _controller.value.duration) { _controller.seekTo(Duration.zero); _controller.play(); } else if (_controller.value.isPlaying) { _controller.pause(); } else { _controller.play(); } }); }, child: Icon(_controller.value.position >= _controller.value.duration ? Icons.replay : _controller.value.isPlaying ? Icons.pause : Icons.play_arrow)), ], ); }
}
