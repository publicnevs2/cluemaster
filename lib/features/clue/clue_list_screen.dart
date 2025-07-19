import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import 'clue_detail_screen.dart';

class ClueListScreen extends StatefulWidget {
  const ClueListScreen({super.key});

  @override
  State<ClueListScreen> createState() => _ClueListScreenState();
}

class _ClueListScreenState extends State<ClueListScreen> {
  final ClueService _clueService = ClueService();
  Map<String, Clue> _clues = {};
  Set<String> _viewedCodes = {};

  @override
  void initState() {
    super.initState();
    _loadClues();
  }

  Future<void> _loadClues() async {
    final loaded = await _clueService.loadClues();
    setState(() {
      _clues = loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final codes = _clues.keys.toList()..sort();
    final total = codes.length;
    final solved = _viewedCodes.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Meine Clues')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Gelöst: $solved von $total',
                style: const TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: codes.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final code = codes[index];
                final clue = _clues[code]!;

                return ListTile(
                  title: Text('$code (${clue.type})'),
                  subtitle: Text(clue.content),
                  trailing: _viewedCodes.contains(code)
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.radio_button_unchecked),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClueDetailScreen(clue: clue),
                      ),
                    );
                    setState(() {
                      _viewedCodes.add(code);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
