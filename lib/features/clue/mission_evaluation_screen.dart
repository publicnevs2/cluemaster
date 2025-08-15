import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';

class MissionEvaluationScreen extends StatefulWidget {
  final Hunt hunt;
  final HuntProgress progress;

  const MissionEvaluationScreen({
    super.key,
    required this.hunt,
    required this.progress,
  });

  @override
  State<MissionEvaluationScreen> createState() => _MissionEvaluationScreenState();
}

class _MissionEvaluationScreenState extends State<MissionEvaluationScreen> {
  late ConfettiController _confettiController;
  late double _score;
  late String _scoreExplanation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _calculateScore();
    // Starte das Konfetti, wenn der Score gut ist
    if (_score >= 80) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _calculateScore() {
    double score = 100.0;
    List<String> deductions = [];

    // 1. Abzug für genutzte Hinweise
    final hintDeduction = widget.progress.hintsUsed * 5.0;
    if (hintDeduction > 0) {
      score -= hintDeduction;
      deductions.add('Hinweise: -${hintDeduction.toInt()}%');
    }

    // 2. Abzug für Zeitüberschreitung (nur wenn eine Zielzeit gesetzt ist)
    final targetTime = widget.hunt.targetTimeInMinutes;
    if (targetTime != null && targetTime > 0) {
      final actualDurationInMinutes = widget.progress.duration.inMinutes;
      final targetDuration = Duration(minutes: targetTime);

      if (actualDurationInMinutes > targetDuration.inMinutes) {
        final overtimePercentage = (actualDurationInMinutes / targetDuration.inMinutes) - 1;
        if (overtimePercentage >= 0.2) {
          score -= 20;
          deductions.add('Zeit: -20%');
        } else if (overtimePercentage >= 0.1) {
          score -= 10;
          deductions.add('Zeit: -10%');
        }
      }
    }

    _score = max(0, score); // Der Score kann nicht unter 0 fallen
    _scoreExplanation = 'Basis: 100% | ${deductions.join(' | ')}';
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MISSION ERFOLGREICH!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.hunt.clues.values.firstWhere((c) => c.isFinalClue).rewardText ?? 'Du hast es geschafft!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(height: 48, thickness: 1),
                    Text(
                      'DEINE AUSWERTUNG',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    _buildStatRow(
                      icon: Icons.timer,
                      label: 'Deine Zeit',
                      value: _formatDuration(widget.progress.duration),
                    ),
                    if (widget.hunt.targetTimeInMinutes != null) ...[
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.flag_outlined,
                        label: 'Zielzeit',
                        value: '${widget.hunt.targetTimeInMinutes} Minuten',
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildStatRow(
                      icon: Icons.error_outline,
                      label: 'Fehlversuche',
                      value: widget.progress.failedAttempts.toString(),
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      icon: Icons.lightbulb_outline,
                      label: 'Genutzte Hinweise',
                      value: widget.progress.hintsUsed.toString(),
                    ),
                    const Divider(height: 48, thickness: 1),
                    Text(
                      'GESAMT-SCORE:',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_score.toInt()}%',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _scoreExplanation,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      onPressed: () {
                        // Gehe 2x zurück: Einmal vom EvaluationScreen und einmal vom HomeScreen
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                      },
                      child: const Text('Zurück zum Hauptmenü', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Das Konfetti-Widget
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 18)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}