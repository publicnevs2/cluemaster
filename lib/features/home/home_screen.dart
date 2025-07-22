// ============================================================
// SECTION: Imports
// ============================================================
import 'package:clue_master/features/shared/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import '../clue/clue_detail_screen.dart';
import '../clue/clue_list_screen.dart';
import '../admin/admin_login_screen.dart';
import '../../main.dart';

// ============================================================
// SECTION: HomeScreen Widget
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ============================================================
// SECTION: State-Klasse
// ============================================================
class _HomeScreenState extends State<HomeScreen> with RouteAware {
  // ============================================================
  // SECTION: State & Controller
  // ============================================================
  final TextEditingController _codeController = TextEditingController();
  final ClueService _clueService = ClueService();

  Map<String, Clue> _clues = {};
  Map<String, String> _normalizedMap = {};
  String? _errorText;

  // ============================================================
  // SECTION: Lifecycle
  // ============================================================
  @override
  void initState() {
    super.initState();
    _loadClues();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  // Diese Methode wird aufgerufen, wenn der Spieler vom Detail-Screen zurückkehrt.
  // Sie lädt die Hinweise neu, um den "gelöst"-Status zu aktualisieren.
  @override
  void didPopNext() {
    _loadClues();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _codeController.dispose();
    super.dispose();
  }

  // ============================================================
  // SECTION: Logik
  // ============================================================
  Future<void> _loadClues() async {
    final loaded = await _clueService.loadClues();
    setState(() {
      _clues = loaded;
      _normalizedMap = {
        for (var code in _clues.keys) code.toLowerCase(): code,
      };
    });
  }

  /// Sucht den Hinweis und navigiert zum Detail-Bildschirm.
  Future<void> _submitCode([String? scannedCode]) async {
    final input = scannedCode ?? _codeController.text.trim();
    if (input.isEmpty) return;

    final norm = input.toLowerCase();

    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(input)) {
      setState(() => _errorText = 'Nur Buchstaben (A–Z) und Zahlen erlaubt');
      return;
    }

    if (_normalizedMap.containsKey(norm)) {
      final originalCode = _normalizedMap[norm]!;
      final clue = _clues[originalCode]!;

      // ============================================================
      // KORREKTUR: Die Logik, die den Hinweis als gelöst markiert,
      // wurde hier entfernt. Das ist jetzt die alleinige Aufgabe
      // des ClueDetailScreen, NACHDEM ein Rätsel gelöst wurde.
      // ============================================================
      // clue.solved = true; // ENTFERNT
      // await _clueService.saveClues(_clues); // ENTFERNT

      if (!mounted) return;
      // Navigiere zum Detail-Bildschirm.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ClueDetailScreen(clue: clue)),
      );
      _codeController.clear();
      setState(() => _errorText = null);
    } else {
      setState(() => _errorText = 'Ungültiger Code');
    }
  }

  /// Öffnet den QR-Scanner und übergibt das Ergebnis an _submitCode.
  Future<void> _scanAndSubmit() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code != null && code.isNotEmpty) {
      _submitCode(code);
    }
  }

  // ============================================================
  // SECTION: UI-Aufbau
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClueMaster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Gefundene Hinweise',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClueListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
              );
            },
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
                  hintText: 'z. B. CODEA',
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
              ElevatedButton(onPressed: () => _submitCode(), child: const Text('Los!')),
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
