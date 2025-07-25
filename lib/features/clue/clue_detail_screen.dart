import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img; // NEU: Import für das image-Paket (fürs Puzzle)
import 'package:clue_master/features/clue/mission_success_screen.dart';
import 'package:clue_master/features/clue/gps_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:vibration/vibration.dart';

import '../../core/services/clue_service.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';

class ClueDetailScreen extends StatefulWidget {
  final Hunt hunt;
  final Clue clue;

  const ClueDetailScreen({super.key, required this.hunt, required this.clue});

  @override
  State<ClueDetailScreen> createState() => _ClueDetailScreenState();
}

class _ClueDetailScreenState extends State<ClueDetailScreen> {
  final _answerController = TextEditingController();
  final _clueService = ClueService();
  final _scrollController = ScrollController();
  final _soundService = SoundService();

  bool _isSolved = false;
  int _wrongAttempts = 0;
  String? _errorMessage;
  bool _contentVisible = false;

  @override
  void initState() {
    super.initState();
    _isSolved = widget.clue.solved;

    if (!widget.clue.hasBeenViewed) {
      widget.clue.hasBeenViewed = true;
      _saveHuntProgress();
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

  Future<void> _saveHuntProgress() async {
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

  void _checkAnswer({String? userAnswer}) async {
    final correctAnswer = widget.clue.answer?.trim().toLowerCase();
    final providedAnswer =
        (userAnswer ?? _answerController.text).trim().toLowerCase();

    if (correctAnswer == providedAnswer) {
      _solveRiddle();
    } else {
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
      _soundService.playSound(SoundEffect.failure);
      setState(() {
        _wrongAttempts++;
        _errorMessage = 'Leider falsch. Versuch es nochmal!';
      });

      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _answerController.clear();
          setState(() => _errorMessage = null);
        }
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
  
  void _startGpsNavigation() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GpsNavigationScreen(hunt: widget.hunt, clue: widget.clue),
      ),
    );

    if (result == true) {
      _solveRiddle();
    }
  }
  
  void _solveRiddle() async {
    if (!mounted || _isSolved) return;

    Vibration.vibrate(duration: 100);
    _soundService.playSound(SoundEffect.success);
    
    setState(() {
      widget.clue.solved = true;
      _isSolved = true;
    });
    
    await _saveHuntProgress();
    if (!mounted) return;

    if (widget.clue.isFinalClue) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MissionSuccessScreen(finalClue: widget.clue)));
    }
  }


  @override
  Widget build(BuildContext context) {
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
                      // HIER WIRD JETZT AUCH DER BILD-EFFEKT ÜBERGEBEN
                      _buildMediaWidget(
                        type: widget.clue.type,
                        content: widget.clue.content,
                        description: widget.clue.description,
                        imageEffect: widget.clue.imageEffect,
                      ),
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
                    Navigator.of(context).pop();
                  },
                  child: const Text('Zurück zur Code-Eingabe'),
                ),
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
        if (_wrongAttempts >= 2 && widget.clue.hint1 != null)
          _buildHintCard(1, widget.clue.hint1!),
        if (_wrongAttempts >= 4 && widget.clue.hint2 != null)
          _buildHintCard(2, widget.clue.hint2!),
      ],
    );
  }

  Widget _buildRewardWidget() {
    return Card(
      color: Colors.green.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("RÄTSEL GELÖST!",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent)),
            const SizedBox(height: 16),
            Text(
              widget.clue.rewardText ?? 'Keine Belohnungsinformation.',
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

// --- HIER FINDEN DIE ÄNDERUNGEN STATT ---
Widget _buildMediaWidget({
  required String type,
  required String content,
  String? description,
  ImageEffect imageEffect = ImageEffect.NONE, // Parameter hinzugefügt
}) {
  Widget mediaWidget;
  switch (type) {
    case 'text':
      mediaWidget = Text(content,
          style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
      break;
    case 'image':
      // Das eigentliche Bild-Widget wird erstellt
      final image = content.startsWith('file://')
          ? Image.file(File(content.replaceFirst('file://', '')))
          : Image.asset(content);

      // Je nach Effekt wird das Bild in ein anderes Widget gewickelt
      switch (imageEffect) {
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
              -1, 0, 0, 0, 255,
              0, -1, 0, 0, 255,
              0, 0, -1, 0, 255,
              0, 0, 0, 1, 0,
            ]),
            child: image,
          );
          break;
        case ImageEffect.PUZZLE:
          mediaWidget = ImagePuzzleWidget(imagePath: content);
          break;
        case ImageEffect.NONE:
        default:
          mediaWidget = image;
      }
      break;
    case 'audio':
      mediaWidget = AudioPlayerWidget(path: content, description: description);
      break;
    case 'video':
      mediaWidget = VideoPlayerWidget(path: content, description: description);
      break;
    default:
      mediaWidget = const Center(child: Text('Unbekannter Inhaltstyp'));
  }

  return Column(
    children: [
      mediaWidget,
      if (description != null && description.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(description,
            style:
                const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center),
      ],
    ],
  );
}

// --- NEUES WIDGET FÜR DAS BILD-PUZZLE ---
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
    // Bild laden
    Uint8List imageBytes;
    if (widget.imagePath.startsWith('file://')) {
      imageBytes = await File(widget.imagePath.replaceFirst('file://', '')).readAsBytes();
    } else {
      final byteData = await rootBundle.load(widget.imagePath);
      imageBytes = byteData.buffer.asUint8List();
    }
    
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return;

    // Bild in 9 Teile zerschneiden
    final pieceWidth = originalImage.width ~/ 3;
    final pieceHeight = originalImage.height ~/ 3;
    final pieces = <Uint8List>[];
    for (int y = 0; y < 3; y++) {
      for (int x = 0; x < 3; x++) {
        final piece = img.copyCrop(originalImage, x: x * pieceWidth, y: y * pieceHeight, width: pieceWidth, height: pieceHeight);
        pieces.add(Uint8List.fromList(img.encodePng(piece)));
      }
    }

    // Teile mischen
    pieces.shuffle(Random());

    setState(() {
      _puzzlePieces = pieces;
    });
  }

  void _onPieceTap(int index) {
    setState(() {
      if (_selectedPieceIndex == null) {
        // Erstes Teil auswählen
        _selectedPieceIndex = index;
      } else {
        // Zweites Teil auswählen -> tauschen
        final temp = _puzzlePieces![_selectedPieceIndex!];
        _puzzlePieces![_selectedPieceIndex!] = _puzzlePieces![index];
        _puzzlePieces![index] = temp;
        _selectedPieceIndex = null; // Auswahl zurücksetzen
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
      // ignore: avoid_print
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
