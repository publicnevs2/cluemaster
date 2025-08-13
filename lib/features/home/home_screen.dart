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

// Dieser Formatter wandelt jede Eingabe automatisch in Großbuchstaben um.
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
  // NEU: Optionaler Parameter, um die Animation von außen zu starten.
  final String? codeToAnimate;

  const HomeScreen({
    super.key,
    required this.hunt,
    this.codeToAnimate, // NEU
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

  // NEU: Statusvariable, die anzeigt, ob gerade eine Animation läuft.
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentHunt = widget.hunt;
    _initializeClues();

    // NEU: Prüfen, ob die Seite mit einem zu animierenden Code aufgerufen wurde.
    if (widget.codeToAnimate != null && widget.codeToAnimate!.isNotEmpty) {
      // Wir starten die Animation erst, nachdem der erste Frame gezeichnet wurde,
      // um einen sauberen Übergang zu gewährleisten.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startCodeAnimation(widget.codeToAnimate!);
      });
    } else {
       // Wenn keine Animation stattfindet, Fokus setzen.
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

  // Diese Methode wird aufgerufen, wenn man zum HomeScreen zurückkehrt.
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
      _normalizedMap = {
        for (var code in _currentHunt.clues.keys) code.toLowerCase(): code,
      };
    });
  }

  Future<void> _refreshHuntData() async {
    final allHunts = await _clueService.loadHunts();
    final updatedHunt = allHunts.firstWhere((h) => h.name == widget.hunt.name,
        orElse: () => _currentHunt);
    setState(() {
      _currentHunt = updatedHunt;
      _initializeClues();
    });
  }

  // NEU: Die komplette Animations-Logik
  void _startCodeAnimation(String code) {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _showError = false; // Fehler-Status zurücksetzen
      _codeController.clear();
    });

    int charIndex = 0;
    // Ein Timer, der alle 200 Millisekunden ein Zeichen "tippt".
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (charIndex < code.length) {
        _soundService.playSound(SoundEffect.buttonClick);
        _codeController.text += code[charIndex];
        charIndex++;
      } else {
        timer.cancel();
        // Nach der Animation wird automatisch die Code-Prüfung ausgelöst.
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _submitCode(code);
            // Animation-Status wird nach der Überprüfung zurückgesetzt.
             setState(() => _isAnimating = false);
          }
        });
      }
    });
  }


  // ANGEPASST: Die Methode wartet jetzt auf ein Ergebnis vom ClueDetailScreen.
  Future<void> _submitCode([String? code]) async {
    // Wenn eine Animation läuft, wird die Eingabe ignoriert.
    if (_isAnimating && code == null) return;
    
    Vibration.vibrate(duration: 50);
    if(code == null) _soundService.playSound(SoundEffect.buttonClick);
    
    final input = code ?? _codeController.text.trim();
    if (input.isEmpty) return;
    
    final norm = input.toLowerCase();

    if (_normalizedMap.containsKey(norm)) {
      if(code == null) _soundService.playSound(SoundEffect.clueUnlocked);
      
      final originalCode = _normalizedMap[norm]!;
      final clue = _currentHunt.clues[originalCode]!;

      if (!mounted) return;

      // HIER DIE WICHTIGE ÄNDERUNG: Wir warten auf ein Ergebnis (den nächsten Code).
      final nextCodeToAnimate = await Navigator.push<String>(
        context,
        MaterialPageRoute(
            builder: (_) => ClueDetailScreen(hunt: _currentHunt, clue: clue)),
      );

      // Nach der Rückkehr von der Detail-Seite:
      _codeController.clear();
      setState(() => _showError = false);
      _codeFocusNode.requestFocus();

      // Wenn ein Code zurückgegeben wurde, starte die nächste Animation.
      if (nextCodeToAnimate != null && nextCodeToAnimate.isNotEmpty) {
        _startCodeAnimation(nextCodeToAnimate);
      }

    } else {
      _soundService.playSound(SoundEffect.failure);
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
      setState(() => _showError = true);
      _codeController.clear();
      _codeFocusNode.requestFocus();
    }
  }

  Future<void> _scanAndSubmit() async {
    if (_isAnimating) return; // Verhindert Scan während der Animation

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

  @override
  Widget build(BuildContext context) {
    final totalClues = _currentHunt.clues.length;
    final viewedClues =
        _currentHunt.clues.values.where((c) => c.hasBeenViewed).length;
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
        color: _isAnimating ? Colors.amber.withOpacity(0.1) : Colors.grey[900], // NEU: Visuelles Feedback
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
                length: 6, // Wichtig: Die Animation stoppt bei dieser Länge.
                keyboardType: TextInputType.text,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
                forceErrorState: _showError,
                // NEU: Deaktiviert die manuelle Eingabe während der Animation.
                enabled: !_isAnimating, 
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
                // NEU: Button wird während der Animation deaktiviert.
                onPressed: _isAnimating ? null : _scanAndSubmit,
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