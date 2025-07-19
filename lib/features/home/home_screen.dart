// ============================================================
// Datei: lib/features/home/home_screen.dart
// ============================================================

// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import '../clue/clue_detail_screen.dart';
import '../clue/clue_list_screen.dart';
import '../admin/admin_login_screen.dart';
import '../../main.dart'; // für routeObserver

// ============================================================
// SECTION: HomeScreen Widget
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ============================================================
// SECTION: State & Controller
// ============================================================
class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final TextEditingController _codeController = TextEditingController();
  final ClueService _clueService = ClueService();

  Map<String, Clue> _clues = {};
  Map<String, String> _normalizedMap = {};
  String? _errorText;

// ============================================================
// SECTION: Lifecycle & RouteAware
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

  @override
  void didPopNext() {
    // Bei Rückkehr: neu laden, damit Location- und solved-Flags aktuell sind
    _loadClues();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _codeController.dispose();
    super.dispose();
  }

// ============================================================
// SECTION: Helper-Methoden
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

  Future<void> _submitCode() async {
    final input = _codeController.text.trim();
    final norm = input.toLowerCase();

    // 1) Nur alphanumerisch erlaubt?
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(input)) {
      setState(() => _errorText = 'Nur Buchstaben (A–Z) und Zahlen erlaubt');
      return;
    }

    // 2) Case-insensitive Lookup
    if (_normalizedMap.containsKey(norm)) {
      final originalCode = _normalizedMap[norm]!;
      final clue = _clues[originalCode]!;

      // 3) solved-Flag setzen und speichern
      clue.solved = true;
      await _clueService.saveClues(_clues);

      // 4) Navigieren und Fehler zurücksetzen
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

// ============================================================
// SECTION: Build-Method (UI-Aufbau)
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
                  hintText: 'z. B. codeA',
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
              ElevatedButton(onPressed: _submitCode, child: const Text('Los!')),
            ],
          ),
        ),
      ),
    );
  }
}
