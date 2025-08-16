// lib/features/clue/clue_detail_screen.dart

import 'dart:async';
import 'package:clue_master/features/clue/gps_navigation_screen.dart';
import 'package:clue_master/features/shared/game_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:clue_master/features/clue/mission_evaluation_screen.dart';

import '../../core/services/clue_service.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';
import '../shared/media_widgets.dart';

class ClueDetailScreen extends StatefulWidget {
  final Hunt hunt;
  final Clue clue;
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
  int _localFailedAttempts = 0;
  bool _hint1Triggered = false;
  bool _hint2Triggered = false;
  Timer? _stopwatchTimer;
  Duration _elapsedDuration = Duration.zero;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _isSolved = widget.clue.solved;

    if (_hasAccess && !widget.clue.hasBeenViewed) {
      widget.clue.hasBeenViewed = true;
      // ============================================================
      // WICHTIG: Setzt den Zeitstempel beim ersten Betrachten
      // ============================================================
      widget.clue.viewedTimestamp = DateTime.now();
      _saveHuntProgressInHuntFile(widget.clue);
    }

    _startStopwatch();

    Timer(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _contentVisible = true);
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _scrollController.dispose();
    _soundService.dispose();
    _stopwatchTimer?.cancel();
    super.dispose();
  }

  void _checkAccess() {
    final requiredItemId = widget.clue.requiredItemId;
    if (requiredItemId == null || requiredItemId.isEmpty) {
      _hasAccess = true;
      return;
    }
    _hasAccess = widget.huntProgress.collectedItemIds.contains(requiredItemId);
  }

  void _startStopwatch() {
    if (widget.huntProgress.startTime == null || _stopwatchTimer?.isActive == true) return;
    _elapsedDuration = widget.huntProgress.duration;
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final duration = widget.huntProgress.duration;
      if (mounted) {
        setState(() {
          _elapsedDuration = duration;
        });
      }
    });
  }

  Future<void> _saveHuntProgressInHuntFile(Clue clueToSave) async {
    final allHunts = await _clueService.loadHunts();
    final huntIndex = allHunts.indexWhere((h) => h.name == widget.hunt.name);
    if (huntIndex != -1) {
      final clueKey = clueToSave.code;
      if (allHunts[huntIndex].clues.containsKey(clueKey)) {
        allHunts[huntIndex].clues[clueKey] = clueToSave;
        await _clueService.saveHunts(allHunts);
      }
    }
  }

  void _checkAnswer({String? userAnswer}) async {
    final correctAnswer = widget.clue.answer?.trim().toLowerCase();
    final providedAnswer = (userAnswer ?? _answerController.text).trim().toLowerCase();

    if (correctAnswer == providedAnswer) {
      await _solveRiddle();
    } else {
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
      _soundService.playSound(SoundEffect.failure);
      setState(() {
        _localFailedAttempts++;
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

  Future<void> _solveRiddle() async {
    if (!mounted || _isSolved) return;

    Vibration.vibrate(duration: 100);
    _soundService.playSound(SoundEffect.success);

    _awardItemReward();

    widget.clue.solved = true;
    await _saveHuntProgressInHuntFile(widget.clue);

    if (mounted) {
      setState(() {
        _isSolved = true;
      });
    }

    if (widget.clue.isFinalClue) {
      widget.huntProgress.endTime = DateTime.now();
      _stopwatchTimer?.cancel();

      if (mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MissionEvaluationScreen(
                  hunt: widget.hunt,
                  progress: widget.huntProgress,
                ),
              ),
            );
          }
        });
      }
    }
  }
  
  Future<void> _makeDecision(int choiceIndex) async {
    if (!mounted || _isSolved) return;

    Vibration.vibrate(duration: 50);
    _soundService.playSound(SoundEffect.buttonClick);
    
    _awardItemReward();

    widget.clue.solved = true;
    await _saveHuntProgressInHuntFile(widget.clue);

    if (mounted) {
      setState(() {
        _isSolved = true;
      });
    }

    String? nextCode;
    if (widget.clue.decisionNextClueCodes != null && widget.clue.decisionNextClueCodes!.length > choiceIndex) {
      nextCode = widget.clue.decisionNextClueCodes![choiceIndex];
    }
    
    if (mounted) {
      Navigator.of(context).pop(nextCode);
    }
  }

  void _awardItemReward() {
    final rewardItemId = widget.clue.rewardItemId;
    if (rewardItemId != null && rewardItemId.isNotEmpty) {
      if (widget.huntProgress.collectedItemIds.add(rewardItemId)) {
        final item = widget.hunt.items[rewardItemId];
        final itemName = item?.name ?? 'unbekannter Gegenstand';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.amber),
                const SizedBox(width: 8),
                Text('Gegenstand erhalten: $itemName'),
              ],
            ),
            backgroundColor: Colors.green[800],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameHeader(
        hunt: widget.hunt,
        huntProgress: widget.huntProgress,
        elapsedTime: _elapsedDuration,
      ),
      body: _hasAccess 
          ? _buildClueContent() 
          : _buildAccessDeniedScreen(),
    );
  }

  Widget _buildClueContent() {
    final bool hasNextCode = _isSolved && (widget.clue.nextClueCode?.isNotEmpty ?? false);
    final String buttonText = hasNextCode ? 'Zur nächsten Station' : 'Nächsten Code eingeben';
    
    final bool showPrimaryButton = !widget.clue.isDecisionRiddle && (!widget.clue.isRiddle || _isSolved);

    return SafeArea(
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
                    buildMediaWidgetForClue(clue: widget.clue),
                    const SizedBox(height: 16),
                    if (widget.clue.isRiddle) ...[
                      const Divider(
                          height: 24, thickness: 1, color: Colors.white24),
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
          if (showPrimaryButton)
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
    );
  }
  
  Widget _buildAccessDeniedScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Zugriff gesperrt',
              style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'SpecialElite'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Du benötigst einen bestimmten Gegenstand, um diese Information entschlüsseln zu können. Suche an anderen Orten weiter.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
             ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zurück zur Code-Eingabe'),
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
            Icon(Icons.check_circle_outline,
                color: Colors.greenAccent.withOpacity(0.8), size: 40),
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
      case RiddleType.DECISION:
        return _buildDecisionRiddleWidget();
      case RiddleType.TEXT:
      default:
        return _buildTextualRiddleWidget(isMultipleChoice: false);
    }
  }

  Widget _buildDecisionRiddleWidget() {
    return Column(
      children: [
        Text(
          widget.clue.question!,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...List.generate(widget.clue.options?.length ?? 0, (index) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ElevatedButton(
              onPressed: () => _makeDecision(index),
              child: Text(widget.clue.options![index], style: const TextStyle(fontSize: 16)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGpsRiddlePrompt() {
    return Column(
      children: [
        Text(
          widget.clue.question!,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
    if (_localFailedAttempts >= 2 && widget.clue.hint1 != null && !_hint1Triggered) {
      widget.huntProgress.hintsUsed++;
      _hint1Triggered = true;
    }
    if (_localFailedAttempts >= 4 && widget.clue.hint2 != null && !_hint2Triggered) {
      widget.huntProgress.hintsUsed++;
      _hint2Triggered = true;
    }

    return Column(
      children: [
        Text(
          widget.clue.question!,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
        if (_localFailedAttempts >= 2 && widget.clue.hint1 != null)
          _buildHintCard(1, widget.clue.hint1!),
        if (_localFailedAttempts >= 4 && widget.clue.hint2 != null)
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
