import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
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
      case 'audio':
        return AudioPlayerWidget(path: clue.content, description: clue.description);
      case 'video':
        return VideoPlayerWidget(path: clue.content, description: clue.description);
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
    // Die Endlosschleife wird hier auf 'false' gesetzt.
    _controller.setLooping(false); 
    // Wir fügen einen Listener hinzu, um das UI neu zu zeichnen, wenn sich der Status ändert (z.B. von Play zu Pause).
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
                // Das Video wird in einen Container mit maximaler Höhe gepackt.
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
                // Wenn das Video am Ende ist, spule zurück und spiele ab.
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
            // Das Icon ändert sich jetzt je nach Zustand (Play, Pause, Replay).
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
