import 'package:clue_master/features/shared/qr_scanner_screen.dart'; // NEUER IMPORT
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import '../clue/clue_detail_screen.dart';
import '../clue/clue_list_screen.dart';
import '../admin/admin_login_screen.dart';
import '../../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final TextEditingController _codeController = TextEditingController();
  final ClueService _clueService = ClueService();

  Map<String, Clue> _clues = {};
  Map<String, String> _normalizedMap = {};
  String? _errorText;

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

  Future<void> _loadClues() async {
    final loaded = await _clueService.loadClues();
    setState(() {
      _clues = loaded;
      _normalizedMap = {
        for (var code in _clues.keys) code.toLowerCase(): code,
      };
    });
  }

  // Die Funktion kann jetzt optional einen gescannten Code direkt verarbeiten
  Future<void> _submitCode([String? scannedCode]) async {
    // Wenn ein gescannter Code übergeben wird, nutze ihn. Ansonsten nimm den aus dem Textfeld.
    final input = scannedCode ?? _codeController.text.trim();
    final norm = input.toLowerCase();

    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(input)) {
      setState(() => _errorText = 'Nur Buchstaben (A–Z) und Zahlen erlaubt');
      return;
    }

    if (_normalizedMap.containsKey(norm)) {
      final originalCode = _normalizedMap[norm]!;
      final clue = _clues[originalCode]!;

      clue.solved = true;
      await _clueService.saveClues(_clues);

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

  // NEUE FUNKTION zum Scannen für den Spieler
  Future<void> _scanAndSubmit() async {
    // Öffnet die Scanner-Seite
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );

    // Wenn ein Code zurückkommt, wird er direkt an die Logik übergeben
    if (code != null && code.isNotEmpty) {
      _submitCode(code);
    }
  }

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
              
              // NEUE UI-ELEMENTE für die "oder"-Option
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