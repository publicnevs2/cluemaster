// lib/features/home/home_screen.dart

import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:clue_master/core/services/sound_service.dart';
import 'package:clue_master/features/shared/game_header.dart';
import 'package:clue_master/features/shared/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pinput/pinput.dart';
import 'package:vibration/vibration.dart';

import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';
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
  final HuntProgress huntProgress;
  final String? codeToAnimate;

  const HomeScreen({
    super.key,
    required this.hunt,
    required this.huntProgress,
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
  bool _isBusy = false;

  late HuntProgress _huntProgress;
  Timer? _stopwatchTimer;
  Duration _elapsedDuration = Duration.zero;

  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    _currentHunt = widget.hunt;
    _huntProgress = widget.huntProgress;

    _initializeClues();

    if (_huntProgress.startTime != null) {
      _startStopwatch();
      _startDistanceTracking();
    }

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
    _startStopwatch();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _codeController.dispose();
    _codeFocusNode.dispose();
    _soundService.dispose();
    _stopwatchTimer?.cancel();
    _positionStreamSubscription?.cancel();
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

  void _startStopwatch() {
    if (_huntProgress.startTime == null || _stopwatchTimer?.isActive == true) return;

    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsedDuration = _huntProgress.duration;
        });
      }
    });
  }

  void _stopStopwatch() {
    _stopwatchTimer?.cancel();
  }

  Future<void> _startDistanceTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Standortdienste sind deaktiviert.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Standortberechtigung wurde verweigert.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Standortberechtigung wurde permanent verweigert.');
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
      if (!mounted) return;

      setState(() {
        if (_lastPosition != null) {
          final distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          _huntProgress.distanceWalkedInMeters += distance;
        }
        _lastPosition = position;
      });
    }, onError: (error) {
      debugPrint('Fehler bei der Standortabfrage: $error');
    });
  }

  void _startCodeAnimation(String code) {
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
    if (!_isBusy) {
      setState(() {
        _isBusy = true;
      });
    }

    final input = code.trim();
    if (input.isEmpty) {
      setState(() {
        _isBusy = false;
      });
      return;
    }

    final norm = input.toLowerCase();

    if (_normalizedMap.containsKey(norm)) {
      if (_huntProgress.startTime == null) {
        setState(() {
          _huntProgress.startTime = DateTime.now();
          _startStopwatch();
          _startDistanceTracking();
        });
      }

      if (!code.toUpperCase().contains('START')) {
        _soundService.playSound(SoundEffect.clueUnlocked);
      }
      final originalCode = _normalizedMap[norm]!;
      final clue = _currentHunt.clues[originalCode]!;

      if (!mounted) return;

      _stopStopwatch();

      final nextCodeFromClue = await Navigator.push<String>(
        context,
        MaterialPageRoute(
            builder: (_) => ClueDetailScreen(
                  hunt: _currentHunt,
                  clue: clue,
                  huntProgress: _huntProgress,
                )),
      );

      await _refreshHuntData();

      setState(() {
        _showError = false;
        _codeController.clear();
      });

      final nextCodeToProcess = nextCodeFromClue ?? clue.nextClueCode;
      if (nextCodeToProcess != null && nextCodeToProcess.isNotEmpty) {
        final previousClue = _currentHunt.clues[originalCode]!;
        if (previousClue.autoTriggerNextClue) {
          _startCodeAnimation(nextCodeToProcess);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Nächster Code freigeschaltet: $nextCodeToProcess')),
          );
          _codeFocusNode.requestFocus();
          setState(() {
            _isBusy = false;
          });
        }
      } else {
        _codeFocusNode.requestFocus();
        setState(() {
          _isBusy = false;
        });
      }
    } else {
      setState(() {
        _huntProgress.failedAttempts++;
      });

      _soundService.playSound(SoundEffect.failure);
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
      setState(() {
        _showError = true;
        _codeController.clear();
        _isBusy = false;
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
      appBar: GameHeader(
        hunt: _currentHunt,
        huntProgress: _huntProgress,
        elapsedTime: _elapsedDuration,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const AutoSizeText(
                'Missions-Code eingeben:',
                style: TextStyle(fontSize: 24),
                maxLines: 1,
              ),
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
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}