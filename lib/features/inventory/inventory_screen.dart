// lib/features/inventory/inventory_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/hunt_progress.dart';
import '../../data/models/item.dart';
import '../../data/models/hunt.dart';

class InventoryScreen extends StatelessWidget {
  final Hunt hunt;
  final HuntProgress huntProgress;

  const InventoryScreen({
    super.key,
    required this.hunt,
    required this.huntProgress,
  });

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // HIER IST DIE ECHTE LOGIK
    // ============================================================
    final List<Item> collectedItems = huntProgress.collectedItemIds
        .map((itemId) => hunt.items[itemId]) // Finde das Item in der Hunt-Bibliothek
        .where((item) => item != null) // Filtere mögliche Fehler aus
        .cast<Item>()
        .toList();
    // ============================================================

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rucksack / Inventar'),
      ),
      body: collectedItems.isEmpty
          ? _buildEmptyState()
          : _buildItemGrid(context, collectedItems),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.backpack_outlined, size: 80, color: Colors.white38),
            SizedBox(height: 16),
            Text(
              'Dein Rucksack ist noch leer.',
              style: TextStyle(fontSize: 20, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Finde Gegenstände an Stationen oder auf deinem Weg. Sie könnten bei zukünftigen Rätseln entscheidend sein!',
              style: TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemGrid(BuildContext context, List<Item> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemTile(context, item);
      },
    );
  }

  Widget _buildItemTile(BuildContext context, Item item) {
    return GestureDetector(
      onTap: () {
        // TODO: Item-Detail-Ansicht öffnen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detailansicht für "${item.name}" kommt bald.')),
        );
      },
      child: Card(
        color: Colors.white.withOpacity(0.1),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  // Wir verwenden hier das thumbnailPath, aber da wir noch keine
                  // echten Bilder haben, zeigen wir ein Platzhalter-Icon.
                  // Später wird hier Image.asset(item.thumbnailPath) stehen.
                  child: Icon(Icons.inventory_2_outlined, size: 40, color: Colors.amber[200]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}