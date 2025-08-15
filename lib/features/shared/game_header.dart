import 'package:clue_master/core/services/sound_service.dart';
import 'package:clue_master/features/admin/admin_login_screen.dart';
import 'package:clue_master/features/clue/clue_list_screen.dart';
import 'package:flutter/material.dart';

import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';
import '../inventory/inventory_screen.dart'; // NEU: Import für den Inventar-Screen

class GameHeader extends StatelessWidget implements PreferredSizeWidget {
  final Hunt hunt;
  final HuntProgress huntProgress;
  final Duration elapsedTime;

  const GameHeader({
    super.key,
    required this.hunt,
    required this.huntProgress,
    required this.elapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    final soundService = SoundService();
    final totalClues = hunt.clues.length;
    final viewedClues = hunt.clues.values.where((c) => c.hasBeenViewed).length;
    
    final int itemCount = huntProgress.collectedItemIds.length;

    String formattedTime =
        '${elapsedTime.inHours.toString().padLeft(2, '0')}:${(elapsedTime.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}';

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black.withOpacity(0.7),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hunt.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpecialElite',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'SpecialElite',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Station: $viewedClues/$totalClues',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'SpecialElite',
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      child: LinearProgressIndicator(
                        value: totalClues > 0 ? viewedClues / totalClues : 0.0,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Badge(
                  label: Text(itemCount.toString()),
                  isLabelVisible: itemCount > 0,
                  child: IconButton(
                    icon: const Icon(Icons.backpack_outlined),
                    onPressed: () {
                      // =======================================================
                      // GEÄNDERT: Öffnet jetzt den neuen Inventar-Screen
                      // =======================================================
                      soundService.playSound(SoundEffect.buttonClick);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InventoryScreen(
                            hunt: hunt,
                            huntProgress: huntProgress,
                          ),
                        ),
                      );
                      // =======================================================
                    },
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu),
                  onSelected: (value) {
                    soundService.playSound(SoundEffect.buttonClick);
                    if (value == 'code_entry') {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else if (value == 'list') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClueListScreen(
                            hunt: hunt,
                            huntProgress: huntProgress,
                          ),
                        ),
                      );
                    } else if (value == 'admin') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminLoginScreen()),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'code_entry',
                      child: ListTile(
                        leading: Icon(Icons.keyboard_return_outlined),
                        title: Text('Zur Code-Eingabe'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'list',
                      child: ListTile(
                        leading: Icon(Icons.list_alt_outlined),
                        title: Text('Logbuch / Hinweise'),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'admin',
                      child: ListTile(
                        leading: Icon(Icons.admin_panel_settings_outlined),
                        title: Text('Admin-Bereich'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75.0);
}