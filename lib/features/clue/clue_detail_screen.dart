import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:clue_master/features/clue/mission_success_screen.dart';
import 'package:clue_master/features/clue/gps_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:vibration/vibration.dart';

import '../../core/services/clue_service.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
// WICHTIGER IMPORT für unser Statistik-Datenmodell
import '../../data/models/hunt_progress.dart';

class ClueDetailScreen extends StatefulWidget {
  final Hunt hunt;
  final Clue clue;
  // NIMMT DAS LOGBUCH VOM HOMESCREEN ENTGEGEN
  final HuntProgress huntProgress;

  const ClueDetailScreen({
    super.key,
    required this.hunt,
    required this.clue,
    required this.huntProgress,
  });

  @override
  State<ClueDetailScreen> createState() => _ClueDetailScreenState();
}

class _ClueDetailScreenState extends State<ClueDetailScreen> {
  final _answerController = TextEditingController();
  final _clueService = ClueService();
  final _scrollController = ScrollController();
  final _soundService = SoundService();

  bool _isSolved = false;
  String? _errorMessage;
  bool _contentVisible = false;

  @override
  void initState() {
    super.initState();
    _isSolved = widget.clue.solved;

    if (!widget.clue.hasBeenViewed) {
      widget.clue.hasBeenViewed = true;
      _saveHuntProgressInHuntFile(); // Speichert den "viewed" Status
    }

    Timer(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _contentVisible = true);
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _scrollController.dispose();
    _soundService.dispose();
    super.dispose();
  }

  /// Speichert den Basis-Fortschritt in der `hunts.json` (z.B. `hasBeenViewed`, `solved`).
  Future<void> _saveHuntProgressInHuntFile() async {
    final allHunts = await _clueService.loadHunts();
    final huntIndex = allHunts.indexWhere((h) => h.name == widget.hunt.name);
    if (huntIndex != -1) {
      final clueKey = widget.clue.code;
      if (allHunts[huntIndex].clues.containsKey(clueKey)) {
        allHunts[huntIndex].clues[clueKey] = widget.clue;
        await _clueService.saveHunts(allHunts);
      }
    }
  }

  /// Prüft die Antwort des Spielers.
  void _checkAnswer({String? userAnswer}) async {
    final correctAnswer = widget.clue.answer?.trim().toLowerCase();
    final providedAnswer =
        (userAnswer ?? _answerController.text).trim().toLowerCase();

    if (correctAnswer == providedAnswer) {
      await _solveRiddle();
    } else {
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
      _soundService.playSound(SoundEffect.failure);
      setState(() {
        // Der Zähler im Logbuch wird erhöht.
        widget.huntProgress.failedAttempts++;
        _errorMessage = 'Leider falsch. Versuch es nochmal!';
      });

      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _answerController.clear();
          setState(() => _errorMessage = null);
        }
      });
    }
  }

  /// Startet die GPS-Navigation.
  void _startGpsNavigation() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GpsNavigationScreen(clue: widget.clue),
      ),
    );

    if (result == true) {
      await _solveRiddle();
    }
  }

  /// Löst das Rätsel, stoppt die Zeit und speichert den Erfolg.
  Future<void> _solveRiddle() async {
    if (!mounted || _isSolved) return;

    Vibration.vibrate(duration: 100);
    _soundService.playSound(SoundEffect.success);
    
    widget.clue.solved = true;
    await _saveHuntProgressInHuntFile();

    if (mounted) {
      setState(() {
        _isSolved = true;
      });
    }

    // WENN ES DER FINALE HINWEIS IST:
    if (widget.clue.isFinalClue) {
      // 1. Zeitmessung beenden
      widget.huntProgress.endTime = DateTime.now();
      
      // 2. Den gesamten Erfolg in der Ruhmeshalle (`progress_history.json`) speichern
      await _clueService.saveHuntProgress(widget.huntProgress);

      // 3. Zum finalen Erfolgs-Screen navigieren
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => MissionSuccessScreen(finalClue: widget.clue)));
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNextCode = _isSolved && (widget.clue.nextClueCode?.isNotEmpty ?? false);
    final String buttonText = hasNextCode ? 'Zur nächsten Station' : 'Nächsten Code eingeben';

    return Scaffold(
      appBar: AppBar(title: const Text('Eingehende Nachricht')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: AnimatedOpacity(
                  opacity: _contentVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      _buildMediaWidget(clue: widget.clue),
                      const SizedBox(height: 16),
                      if (widget.clue.isRiddle) ...[
                        const Divider(height: 24, thickness: 1, color: Colors.white24),
                        if (_isSolved)
                          _buildRewardWidget()
                        else
                          _buildRiddleWidget(),
                      ]
                    ],
                  ),
                ),
              ),
            ),
            if (!widget.clue.isRiddle || _isSolved)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Vibration.vibrate(duration: 50);
                    _soundService.playSound(SoundEffect.buttonClick);
                    
                    Navigator.of(context).pop(widget.clue.nextClueCode);
                  },
                  child: Text(buttonText),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardWidget() {
    return Card(
      color: Colors.green.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              Icon(Icons.check_circle_outline, color: Colors.greenAccent.withOpacity(0.8), size: 40),
              const SizedBox(height: 12),
            Text(
              widget.clue.rewardText ?? 'Gut gemacht!',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRiddleWidget() {
    switch (widget.clue.riddleType) {
      case RiddleType.GPS:
        return _buildGpsRiddlePrompt();
      case RiddleType.MULTIPLE_CHOICE:
        return _buildTextualRiddleWidget(isMultipleChoice: true);
      case RiddleType.TEXT:
      default:
        return _buildTextualRiddleWidget(isMultipleChoice: false);
    }
  }
  
  Widget _buildGpsRiddlePrompt() {
    return Column(
      children: [
        Text(
          widget.clue.question!,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.explore_outlined),
          label: const Text('Navigation zum Zielort starten'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: _startGpsNavigation,
        ),
      ],
    );
  }

  Widget _buildTextualRiddleWidget({required bool isMultipleChoice}) {
    // Der Zähler für Fehlversuche kommt jetzt direkt aus dem Logbuch
    final wrongAttempts = widget.huntProgress.failedAttempts;

    return Column(
      children: [
        Text(
          widget.clue.question!,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        isMultipleChoice
            ? _buildMultipleChoiceOptions()
            : _buildTextAnswerField(),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(_errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
          ),
        if (wrongAttempts >= 2 && widget.clue.hint1 != null)
          _buildHintCard(1, widget.clue.hint1!),
        if (wrongAttempts >= 4 && widget.clue.hint2 != null)
          _buildHintCard(2, widget.clue.hint2!),
      ],
    );
  }

  Widget _buildMultipleChoiceOptions() {
    return Column(
      children: (widget.clue.options ?? []).map((option) {
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
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'Antwort...'),
            onSubmitted: (_) => _checkAnswer(),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: Colors.amber),
          icon: const Icon(Icons.send, color: Colors.black),
          onPressed: () => _checkAnswer(),
        ),
      ],
    );
  }

  Widget _buildHintCard(int level, String hintText) {
    return Card(
      margin: const EdgeInsets.only(top: 24),
      color: Colors.amber.withOpacity(0.2),
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
}

// ===========================================================
// ANHANG: ALLE DEINE MEDIA-WIDGETS (unverändert beibehalten)
// ===========================================================

Widget _buildMediaWidget({required Clue clue}) {
  Widget mediaWidget;
  switch (clue.type) {
    case 'text':
      mediaWidget = _buildTextWidgetWithEffect(clue.content, clue.textEffect);
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
              0, -1,  0,  0, 255,
              0,  0, -1,  0, 255,
              0,  0,  0,  1, 0,
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

Widget _buildTextWidgetWithEffect(String content, TextEffect effect) {
  switch (effect) {
    case TextEffect.MORSE_CODE:
      return MorseCodeWidget(text: content);
    case TextEffect.REVERSE:
      return Text(content.split('').reversed.join(''),
          style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
    case TextEffect.NO_VOWELS:
      return Text(content.replaceAll(RegExp(r'[aeiouAEIOU]'), ''),
          style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
    case TextEffect.MIRROR_WORDS:
      final mirrored =
          content.split(' ').map((word) => word.split('').reversed.join('')).join(' ');
      return Text(mirrored,
          style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
    case TextEffect.NONE:
    default:
      return Text(content,
          style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
  }
}

class MorseCodeWidget extends StatelessWidget {
  final String text;
  const MorseCodeWidget({super.key, required this.text});

  static const Map<String, String> _morseCodeMap = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
    'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
    'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
    'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
    'Y': '-.--', 'Z': '--..', '1': '.----', '2': '..---', '3': '...--',
    '4': '....-', '5': '.....', '6': '-....', '7': '--...', '8': '---..',
    '9': '----.', '0': '-----', ' ': '/'
  };

  String _toMorseCode(String input) {
    return input
        .toUpperCase()
        .split('')
        .map((char) => _morseCodeMap[char] ?? '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _toMorseCode(text),
          style: const TextStyle(fontSize: 24, fontFamily: 'SpecialElite'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        IconButton(
          icon: const Icon(Icons.volume_up_outlined, size: 40),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Akustische Morsecode-Wiedergabe ist noch in Entwicklung.'),
            ));
          },
        ),
      ],
    );
  }
}

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