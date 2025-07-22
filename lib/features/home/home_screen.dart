// ============================================================
// SECTION: Imports
// ============================================================
import 'package:clue_master/features/shared/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart'; // NEU: Import für das Hunt-Modell
import '../clue/clue_detail_screen.dart';
import '../clue/clue_list_screen.dart';
import '../admin/admin_login_screen.dart';
import '../../main.dart';

// ============================================================
// SECTION: HomeScreen Widget
// ============================================================
class HomeScreen extends StatefulWidget {
  // NEU: Der HomeScreen erwartet jetzt eine 'hunt', die ihm sagt, welches Spiel gespielt wird.
  final Hunt hunt;

  const HomeScreen({super.key, required this.hunt});

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

  // Die Hinweise kommen jetzt direkt von der übergebenen Jagd.
  late Map<String, Clue> _clues;
  late Map<String, String> _normalizedMap;
  String? _errorText;

  // ============================================================
  // SECTION: Lifecycle
  // ============================================================
  @override
  void initState() {
    super.initState();
    // Die Hinweise werden direkt aus der übergebenen Jagd initialisiert.
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

  // Wenn wir zu diesem Screen zurückkehren, laden wir die Hinweise neu,
  // um den 'solved'-Status zu aktualisieren.
  @override
  void didPopNext() {
    _refreshHuntData();
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

  /// Initialisiert die Hinweise aus der übergebenen Jagd.
  void _initializeClues() {
    setState(() {
      _clues = widget.hunt.clues;
      _normalizedMap = {
        for (var code in _clues.keys) code.toLowerCase(): code,
      };
    });
  }

  /// Lädt die Daten der aktuellen Jagd neu.
  Future<void> _refreshHuntData() async {
    final allHunts = await _clueService.loadHunts();
    final updatedHunt = allHunts.firstWhere((h) => h.name == widget.hunt.name, orElse: () => widget.hunt);
    setState(() {
      _clues = updatedHunt.clues;
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

    if (_normalizedMap.containsKey(norm)) {
      final originalCode = _normalizedMap[norm]!;
      final clue = _clues[originalCode]!;

      if (!mounted) return;
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
        // Der Titel zeigt jetzt den Namen der ausgewählten Jagd an.
        title: Text(widget.hunt.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Gefundene Hinweise',
            onPressed: () {
              // TODO: Auch die ClueListScreen muss die 'hunt' übergeben bekommen.
              // Das machen wir im nächsten Schritt.
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
