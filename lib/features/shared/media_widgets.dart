// lib/features/shared/media_widgets.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:clue_master/data/models/clue.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

Widget buildMediaWidgetForClue({required Clue clue}) {
  Widget mediaWidget;
  switch (clue.type) {
    case 'text':
      mediaWidget = MorseCodeWidget(text: clue.content, effect: clue.textEffect);
      break;
    case 'image':
      final image = clue.content.startsWith('file://')
          ? Image.file(File(clue.content.replaceFirst('file://', '')))
          : Image.asset(clue.content);

      switch (clue.imageEffect) {
        case ImageEffect.BLACK_AND_WHITE:
          mediaWidget = ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ]),
            child: image,
          );
          break;
        case ImageEffect.INVERT_COLORS:
          mediaWidget = ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              -1, 0,  0,  0, 255,
               0,-1,  0,  0, 255,
               0, 0, -1,  0, 255,
               0, 0,  0,  1, 0,
            ]),
            child: image,
          );
          break;
        case ImageEffect.PUZZLE:
          mediaWidget = ImagePuzzleWidget(imagePath: clue.content);
          break;
        case ImageEffect.NONE:
        default:
          mediaWidget = image;
      }
      break;
    case 'audio':
      mediaWidget = AudioPlayerWidget(path: clue.content);
      break;
    case 'video':
      mediaWidget = VideoPlayerWidget(path: clue.content);
      break;
    default:
      mediaWidget = const Center(child: Text('Unbekannter Inhaltstyp'));
  }

  return Column(
    children: [
      mediaWidget,
      if (clue.description != null && clue.description!.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(clue.description!,
            style:
                const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center),
      ],
    ],
  );
}

// ============================================================
// STARK ÜBERARBEITET: MorseCodeWidget ist jetzt interaktiv
// ============================================================
class MorseCodeWidget extends StatefulWidget {
  final String text;
  final TextEffect effect;

  const MorseCodeWidget({
    super.key,
    required this.text,
    this.effect = TextEffect.NONE,
  });

  @override
  State<MorseCodeWidget> createState() => _MorseCodeWidgetState();
}

class _MorseCodeWidgetState extends State<MorseCodeWidget> {
  final AudioPlayer _dotPlayer = AudioPlayer();
  final AudioPlayer _dashPlayer = AudioPlayer();
  bool _isPlaying = false;

  static const Map<String, String> _morseCodeMap = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
    'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
    'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
    'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
    'Y': '-.--', 'Z': '--..', '1': '.----', '2': '..---', '3': '...--',
    '4': '....-', '5': '.....', '6': '-....', '7': '--...', '8': '---..',
    '9': '----.', '0': '-----', ' ': '/'
  };

  @override
  void initState() {
    super.initState();
    _dotPlayer.setAsset('assets/audio/dot.mp3');
    _dashPlayer.setAsset('assets/audio/dash.mp3');
  }

  @override
  void dispose() {
    _dotPlayer.dispose();
    _dashPlayer.dispose();
    super.dispose();
  }

  String _applyEffect(String content, TextEffect effect) {
    switch (effect) {
      case TextEffect.MORSE_CODE:
        return _toMorseCode(content);
      case TextEffect.REVERSE:
        return content.split('').reversed.join('');
      case TextEffect.NO_VOWELS:
        return content.replaceAll(RegExp(r'[aeiouAEIOU]'), '');
      case TextEffect.MIRROR_WORDS:
        return content.split(' ').map((word) => word.split('').reversed.join('')).join(' ');
      case TextEffect.NONE:
      default:
        return content;
    }
  }

  String _toMorseCode(String input) {
    return input
        .toUpperCase()
        .split('')
        .map((char) => _morseCodeMap[char] ?? '')
        .join(' ');
  }

  Future<void> _playMorseSequence() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);

    final morseString = _toMorseCode(widget.text);

    for (final char in morseString.split('')) {
      if (!mounted) break;
      switch (char) {
        case '.':
          await _dotPlayer.seek(Duration.zero);
          await _dotPlayer.play();
          await Future.delayed(const Duration(milliseconds: 200));
          break;
        case '-':
          await _dashPlayer.seek(Duration.zero);
          await _dashPlayer.play();
          await Future.delayed(const Duration(milliseconds: 400));
          break;
        case ' ':
          await Future.delayed(const Duration(milliseconds: 200));
          break;
        case '/':
          await Future.delayed(const Duration(milliseconds: 400));
          break;
      }
    }
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _applyEffect(widget.text, widget.effect);
    final isMorse = widget.effect == TextEffect.MORSE_CODE;

    return Column(
      children: [
        Text(
          displayText,
          style: TextStyle(
            fontSize: isMorse ? 24 : 18,
            fontFamily: isMorse ? 'SpecialElite' : null,
          ),
          textAlign: TextAlign.center,
        ),
        if (isMorse) ...[
          const SizedBox(height: 16),
          IconButton(
            icon: Icon(_isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline, size: 40),
            color: Colors.amber,
            onPressed: _isPlaying ? null : _playMorseSequence,
          ),
        ]
      ],
    );
  }
}

// ... (Rest der Datei: ImagePuzzleWidget, AudioPlayerWidget, VideoPlayerWidget bleiben unverändert)
class ImagePuzzleWidget extends StatefulWidget {
  final String imagePath;
  const ImagePuzzleWidget({super.key, required this.imagePath});

  @override
  State<ImagePuzzleWidget> createState() => _ImagePuzzleWidgetState();
}

class _ImagePuzzleWidgetState extends State<ImagePuzzleWidget> {
  List<Uint8List>? _puzzlePieces;
  int? _selectedPieceIndex;

  @override
  void initState() {
    super.initState();
    _createPuzzle();
  }

  Future<void> _createPuzzle() async {
    Uint8List imageBytes;
    if (widget.imagePath.startsWith('file://')) {
      imageBytes =
          await File(widget.imagePath.replaceFirst('file://', '')).readAsBytes();
    } else {
      final byteData = await rootBundle.load(widget.imagePath);
      imageBytes = byteData.buffer.asUint8List();
    }

    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return;

    final pieceWidth = originalImage.width ~/ 3;
    final pieceHeight = originalImage.height ~/ 3;
    final pieces = <Uint8List>[];
    for (int y = 0; y < 3; y++) {
      for (int x = 0; x < 3; x++) {
        final piece = img.copyCrop(originalImage,
            x: x * pieceWidth, y: y * pieceHeight, width: pieceWidth, height: pieceHeight);
        pieces.add(Uint8List.fromList(img.encodePng(piece)));
      }
    }

    pieces.shuffle(Random());

    setState(() {
      _puzzlePieces = pieces;
    });
  }

  void _onPieceTap(int index) {
    setState(() {
      if (_selectedPieceIndex == null) {
        _selectedPieceIndex = index;
      } else {
        final temp = _puzzlePieces![_selectedPieceIndex!];
        _puzzlePieces![_selectedPieceIndex!] = _puzzlePieces![index];
        _puzzlePieces![index] = temp;
        _selectedPieceIndex = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_puzzlePieces == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _onPieceTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    border: _selectedPieceIndex == index
                        ? Border.all(color: Colors.amber, width: 4)
                        : null,
                  ),
                  child: Image.memory(_puzzlePieces![index], fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tippe zwei Teile an, um sie zu tauschen.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String path;
  const AudioPlayerWidget({super.key, required this.path});

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
      debugPrint("Fehler beim Laden der Audio-Datei: $e");
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
        const Icon(Icons.audiotrack, size: 120, color: Colors.amber),
        const SizedBox(height: 24),
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return const CircularProgressIndicator();
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_circle_fill, size: 80),
                color: Colors.amber,
                onPressed: _player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause_circle_filled, size: 80),
                color: Colors.amber,
                onPressed: _player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay_circle_filled, size: 80),
                color: Colors.amber,
                onPressed: () => _player.seek(Duration.zero),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        const Text("Audio-Hinweis abspielen"),
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String path;
  const VideoPlayerWidget({super.key, required this.path});

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
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
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
