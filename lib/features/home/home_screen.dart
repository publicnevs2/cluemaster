import 'dart:async';
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Hunt hunt;
  final String? codeToAnimate;

  const HomeScreen({
    super.key,
    required this.hunt,
    this.codeToAnimate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final ClueService _clueService = ClueService();
  final SoundService _soundService = SoundService();

  late Hunt _currentHunt;
  late Map<String, String> _normalizedMap;
  bool _showError = false;

  // Das zentrale Kontroll-Flag. Wenn true, sind alle User-Interaktionen blockiert.
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _currentHunt = widget.hunt;
    _initializeClues();

    if (widget.codeToAnimate != null && widget.codeToAnimate!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startCodeAnimation(widget.codeToAnimate!);
      });
    } else {
      _codeFocusNode.requestFocus();
    }
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
    if (!_isBusy) {
      _refreshHuntData();
    }
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
    _normalizedMap = {
      for (var code in _currentHunt.clues.keys) code.toLowerCase(): code,
    };
  }

  Future<void> _refreshHuntData() async {
    final allHunts = await _clueService.loadHunts();
    if (!mounted) return;
    final updatedHunt = allHunts.firstWhere((h) => h.name == widget.hunt.name,
        orElse: () => _currentHunt);
    setState(() {
      _currentHunt = updatedHunt;
      _initializeClues();
    });
  }

  void _startCodeAnimation(String code) {
    // KORREKTUR: Der fehlerhafte Check wurde entfernt.
    // Die Funktion sperrt jetzt sofort die UI und startet die Animation.
    setState(() {
      _isBusy = true;
      _showError = false;
      _codeController.clear();
    });

    int charIndex = 0;
    Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (charIndex < code.length) {
        _soundService.playSound(SoundEffect.buttonClick);
        setState(() {
          _codeController.text += code[charIndex];
        });
        charIndex++;
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _processCode(code);
          }
        });
      }
    });
  }

  void _submitManualCode() {
    if (_isBusy) return;
    Vibration.vibrate(duration: 50);
    _soundService.playSound(SoundEffect.buttonClick);
    _processCode(_codeController.text);
  }

  Future<void> _processCode(String code) async {
    // Stellt sicher, dass die App als "beschäftigt" markiert ist.
    if (!_isBusy) {
      setState(() { _isBusy = true; });
    }

    final input = code.trim();
    if (input.isEmpty) {
      setState(() { _isBusy = false; }); // Bei leerer Eingabe sofort freigeben.
      return;
    }
    
    final norm = input.toLowerCase();

    if (_normalizedMap.containsKey(norm)) {
      if (!code.toUpperCase().contains('START')) {
         _soundService.playSound(SoundEffect.clueUnlocked);
      }
      final originalCode = _normalizedMap[norm]!;
      final clue = _currentHunt.clues[originalCode]!;

      if (!mounted) return;

      final nextCodeToAnimate = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => ClueDetailScreen(hunt: _currentHunt, clue: clue)),
      );
      
      setState(() {
        clue.hasBeenViewed = true;
        if (clue.solved) {
           _currentHunt.clues[originalCode]!.solved = true;
        }
        _showError = false;
        _codeController.clear();
      });

      if (nextCodeToAnimate != null && nextCodeToAnimate.isNotEmpty) {
        // Die nächste Animation wird gestartet. _isBusy bleibt true.
        _startCodeAnimation(nextCodeToAnimate);
      } else {
        // Die Kette ist beendet. App für manuelle Eingabe freigeben.
        _codeFocusNode.requestFocus();
        setState(() { _isBusy = false; });
      }
    } else {
      _soundService.playSound(SoundEffect.failure);
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
      setState(() {
        _showError = true;
        _codeController.clear();
        _isBusy = false; // Bei Fehler App wieder freigeben
      });
      _codeFocusNode.requestFocus();
    }
  }

  Future<void> _scanAndSubmit() async {
    if (_isBusy) return;
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code != null && code.isNotEmpty) {
      _processCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalClues = _currentHunt.clues.length;
    final viewedClues = _currentHunt.clues.values.where((c) => c.hasBeenViewed).length;
    final double progress = totalClues > 0 ? viewedClues / totalClues : 0.0;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontFamily: 'SpecialElite'),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(8),
        color: _isBusy ? Colors.amber.withOpacity(0.1) : Colors.grey[900],
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
        title: AutoSizeText(_currentHunt.name, maxLines: 1),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'list') {
                _soundService.playSound(SoundEffect.buttonClick);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ClueListScreen(hunt: _currentHunt)),
                );
              } else if (value == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                );
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
                'Fortschritt: ${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.amber[200],
                    letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Missions-Code eingeben:', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 24),
              Pinput(
                controller: _codeController,
                focusNode: _codeFocusNode,
                length: 6,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                enabled: !_isBusy, 
                onCompleted: (pin) => _submitManualCode(),
                onChanged: (_) {
                  if (_showError) setState(() => _showError = false);
                },
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
                forceErrorState: _showError,
              ),
              SizedBox(
                height: 40,
                child: _showError
                    ? const Center(
                        child: Text(
                          'CODE UNGÜLTIG',
                          style: TextStyle(
                              color: Colors.redAccent, fontSize: 16),
                        ),
                      )
                    : null,
              ),
              const Text('oder'),
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.amber[200]),
                onPressed: _isBusy ? null : _scanAndSubmit,
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