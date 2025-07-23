// lib/features/home/home_screen.dart

import 'package:auto_size_text/auto_size_text.dart';
import 'package:clue_master/core/services/sound_service.dart';
import 'package:clue_master/features/shared/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:vibration/vibration.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import '../clue/clue_detail_screen.dart';
import '../clue/clue_list_screen.dart';
import '../admin/admin_login_screen.dart';
import '../../main.dart';

// Dieser Formatter wandelt jede Eingabe automatisch in Großbuchstaben um.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Hunt hunt;
  const HomeScreen({super.key, required this.hunt});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final ClueService _clueService = ClueService();
  final SoundService _soundService = SoundService();

  late Map<String, Clue> _currentClues;
  late Map<String, String> _normalizedMap;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _initializeClues();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _refreshHuntData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _codeController.dispose();
    _codeFocusNode.dispose();
    _soundService.dispose();
    super.dispose();
  }

  void _initializeClues() {
    setState(() {
      _currentClues = widget.hunt.clues;
      _normalizedMap = {
        for (var code in _currentClues.keys) code.toLowerCase(): code,
      };
    });
  }

  Future<void> _refreshHuntData() async {
    final allHunts = await _clueService.loadHunts();
    final updatedHunt = allHunts.firstWhere((h) => h.name == widget.hunt.name,
        orElse: () => widget.hunt);
    setState(() {
      _currentClues = updatedHunt.clues;
       _normalizedMap = {
        for (var code in _currentClues.keys) code.toLowerCase(): code,
      };
    });
  }

  Future<void> _submitCode([String? code]) async {
    Vibration.vibrate(duration: 50);
    _soundService.playSound(SoundEffect.buttonClick);
    final input = code ?? _codeController.text.trim();
    if (input.isEmpty) return;
    final norm = input.toLowerCase();

    if (_normalizedMap.containsKey(norm)) {
      _soundService.playSound(SoundEffect.clueUnlocked);
      final originalCode = _normalizedMap[norm]!;
      final clue = _currentClues[originalCode]!;
      final currentHuntState = Hunt(name: widget.hunt.name, clues: _currentClues);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ClueDetailScreen(hunt: currentHuntState, clue: clue)),
      );
      _codeController.clear();
      setState(() => _showError = false);
    } else {
      _soundService.playSound(SoundEffect.failure);
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
      setState(() => _showError = true);
      _codeController.clear();
      _codeFocusNode.requestFocus();
    }
  }

  Future<void> _scanAndSubmit() async {
    Vibration.vibrate(duration: 50);
    _soundService.playSound(SoundEffect.buttonClick);
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code != null && code.isNotEmpty) {
      _submitCode(code);
    }
  }

  // *** KORREKTUR: REFRESH NACH ADMIN-MODUS ***
  void _navigateToAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    ).then((_) {
      // Diese Zeile wird ausgeführt, wenn man vom Admin-Bereich zurückkehrt.
      _refreshHuntData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalClues = _currentClues.isNotEmpty ? _currentClues.length : 1;
    final solvedClues = _currentClues.values.where((c) => c.solved).length;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'SpecialElite'),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[900],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.amber),
    );
    
    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.redAccent),
    );

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(widget.hunt.name, maxLines: 1),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'list') {
                _soundService.playSound(SoundEffect.buttonClick);
                final currentHuntState = Hunt(name: widget.hunt.name, clues: _currentClues);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ClueListScreen(hunt: currentHuntState)),
                );
              } else if (value == 'admin') {
                _navigateToAdmin(); // Korrigierter Aufruf
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'list',
                child: ListTile(
                  leading: Icon(Icons.list),
                  title: Text('Gefundene Hinweise'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'admin',
                child: ListTile(
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('Admin-Bereich'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Station $solvedClues / $totalClues',
                style: TextStyle(fontSize: 22, color: Colors.amber[200], letterSpacing: 1.5),
              ),
              const SizedBox(height: 24),
              const Text('Missions-Code eingeben:', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 24),
              
              Pinput(
                controller: _codeController,
                focusNode: _codeFocusNode,
                length: 6,
                // *** KORREKTUR: ALPHANUMERISCHE EINGABE ***
                keyboardType: TextInputType.text, // Erlaubt die volle Tastatur
                inputFormatters: [
                  UpperCaseTextFormatter(), // Wandelt alles in Großbuchstaben um
                ],
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
                forceErrorState: _showError,
                autofocus: true,
                onCompleted: (pin) => _submitCode(pin),
                onChanged: (_) {
                  if (_showError) setState(() => _showError = false);
                },
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              ),
              
              SizedBox(
                height: 40,
                child: _showError
                    ? const Center(
                        child: Text(
                          'CODE UNGÜLTIG',
                          style: TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      )
                    : null,
              ),
                
              const Text('oder'),
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.amber[200]),
                onPressed: _scanAndSubmit,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('QR-Code scannen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
