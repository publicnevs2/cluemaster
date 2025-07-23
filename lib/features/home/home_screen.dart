// lib/features/home/home_screen.dart

import 'package:clue_master/core/services/sound_service.dart';
import 'package:clue_master/features/shared/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import '../clue/clue_detail_screen.dart';
import '../clue/clue_list_screen.dart';
import '../admin/admin_login_screen.dart';
import '../../main.dart';

class HomeScreen extends StatefulWidget {
  final Hunt hunt;

  const HomeScreen({super.key, required this.hunt});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final TextEditingController _codeController = TextEditingController();
  final ClueService _clueService = ClueService();
  final SoundService _soundService = SoundService();

  // Diese Variable hält jetzt immer den aktuellsten Stand der Hinweise
  late Map<String, Clue> _currentClues;
  late Map<String, String> _normalizedMap;
  String? _errorText;

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
      // Wir aktualisieren unsere lokale State-Variable mit den frischen Daten
      _currentClues = updatedHunt.clues;
       _normalizedMap = {
        for (var code in _currentClues.keys) code.toLowerCase(): code,
      };
    });
  }

  Future<void> _submitCode([String? scannedCode]) async {
    _soundService.playSound(SoundEffect.buttonClick);
    final input = scannedCode ?? _codeController.text.trim();
    if (input.isEmpty) return;
    final norm = input.toLowerCase();

    if (_normalizedMap.containsKey(norm)) {
      _soundService.playSound(SoundEffect.clueUnlocked);
      final originalCode = _normalizedMap[norm]!;
      final clue = _currentClues[originalCode]!;

      // Erstelle ein frisches Hunt-Objekt für die Detailansicht
      final currentHuntState = Hunt(name: widget.hunt.name, clues: _currentClues);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ClueDetailScreen(hunt: currentHuntState, clue: clue)),
      );
      _codeController.clear();
      setState(() => _errorText = null);
    } else {
      _soundService.playSound(SoundEffect.failure);
      setState(() => _errorText = 'Ungültiger Code');
    }
  }

  Future<void> _scanAndSubmit() async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hunt.name),
        actions: [
          // *** HIER IST DIE KORREKTUR ***
          // Das Menü enthält jetzt nur noch die für den Spieler relevanten Optionen.
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
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Gib deinen Code ein:', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'z. B. START',
                  errorText: _errorText,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _codeController.clear(),
                  ),
                ),
                onSubmitted: (_) => _submitCode(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => _submitCode(), child: const Text('Los!')),
              const SizedBox(height: 12),
              const Text('oder'),
              TextButton.icon(
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
