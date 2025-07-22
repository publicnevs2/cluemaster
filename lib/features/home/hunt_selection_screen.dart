// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import 'home_screen.dart'; // Import für den nächsten Bildschirm

// ============================================================
// SECTION: HuntSelectionScreen Widget
// ============================================================
class HuntSelectionScreen extends StatefulWidget {
  const HuntSelectionScreen({super.key});

  @override
  State<HuntSelectionScreen> createState() => _HuntSelectionScreenState();
}

// ============================================================
// SECTION: State-Klasse
// ============================================================
class _HuntSelectionScreenState extends State<HuntSelectionScreen> {
  // ============================================================
  // SECTION: State & Controller
  // ============================================================
  final ClueService _clueService = ClueService();
  List<Hunt> _hunts = [];
  bool _isLoading = true;

  // ============================================================
  // SECTION: Lifecycle
  // ============================================================
  @override
  void initState() {
    super.initState();
    _loadHunts();
  }

  // ============================================================
  // SECTION: Logik
  // ============================================================
  Future<void> _loadHunts() async {
    final loadedHunts = await _clueService.loadHunts();
    if (mounted) {
      setState(() {
        _hunts = loadedHunts;
        _isLoading = false;
      });
    }
  }

  /// Navigiert zum HomeScreen für die ausgewählte Jagd.
  void _selectHunt(Hunt hunt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(hunt: hunt),
      ),
    );
  }

  // ============================================================
  // SECTION: UI-Aufbau
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schnitzeljagd auswählen'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hunts.isEmpty
              ? const Center(
                  child: Text('Keine Schnitzeljagden verfügbar.'),
                )
              : ListView.builder(
                  itemCount: _hunts.length,
                  itemBuilder: (context, index) {
                    final hunt = _hunts[index];
                    return ListTile(
                      title: Text(hunt.name),
                      subtitle: Text('${hunt.clues.length} Stationen'),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => _selectHunt(hunt),
                    );
                  },
                ),
    );
  }
}
