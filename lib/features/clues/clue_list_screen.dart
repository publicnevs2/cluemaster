import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';

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
    setState(() => _clues = loaded);
  }

  @override
  Widget build(BuildContext context) {
    final codes = _clues.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text("Hinweisliste")),
      body: ListView.builder(
        itemCount: codes.length,
        itemBuilder: (context, index) {
          final code = codes[index];
          final clue = _clues[code]!;

          return ListTile(
            leading: Icon(
              clue.type == 'text' ? Icons.text_snippet : Icons.image,
              color: _viewedCodes.contains(code) ? Colors.green : null,
            ),
            title: Text("Code: $code"),
            subtitle: Text(clue.type == 'text'
                ? clue.content
                : (clue.description ?? 'Bildhinweis')),
            trailing: _viewedCodes.contains(code)
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () {
              setState(() {
                _viewedCodes.add(code);
              });

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClueDetailScreen(clue: clue),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ClueDetailScreen extends StatelessWidget {
  final Clue clue;

  const ClueDetailScreen({super.key, required this.clue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hinweis")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (clue.type == 'text')
              Text(clue.content)
            else
              Column(
                children: [
                  Image.asset(clue.content),
                  if (clue.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        clue.description!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            const Spacer(),
            const Text(
              "(C) Sven Kompe 2025",
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
