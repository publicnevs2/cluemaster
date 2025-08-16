// lib/features/shared/game_header.dart

import 'package:clue_master/core/services/sound_service.dart';
import 'package:clue_master/features/admin/admin_login_screen.dart';
import 'package:flutter/material.dart';

import 'package:clue_master/features/home/home_screen.dart'; 
import 'package:clue_master/features/clue/clue_list_screen.dart';


import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';
import '../inventory/inventory_screen.dart';

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
    final String formattedTime =
        '${elapsedTime.inHours.toString().padLeft(2, '0')}:${(elapsedTime.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}';

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusElement(
                    icon: Icons.timer_outlined,
                    text: formattedTime,
                  ),
                  _buildStatusElement(
                    icon: Icons.flag_outlined,
                    text: 'Station: $viewedClues/$totalClues',
                  ),
                  Row(
                    children: [
                      _buildInventoryButton(context, itemCount, soundService),
                      _buildMenuButton(context, soundService),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusElement({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontFamily: 'SpecialElite',
          ),
        ),
      ],
    );
  }
  
  Widget _buildInventoryButton(BuildContext context, int itemCount, SoundService soundService) {
     return Badge(
      label: Text(itemCount.toString()),
      isLabelVisible: itemCount > 0,
      backgroundColor: Colors.blueGrey,
      textColor: Colors.white,
      smallSize: 8,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: IconButton(
        icon: const Icon(Icons.backpack_outlined),
        onPressed: () {
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
        },
      ),
    );
  }
  
  Widget _buildMenuButton(BuildContext context, SoundService soundService) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      onSelected: (value) {
        soundService.playSound(SoundEffect.buttonClick);
        if (value == 'code_entry') {
          // =======================================================
          // HIER IST DIE NEUE, ROBUSTE LOGIK
          // Wir entfernen alle Spiel-Bildschirme und starten den
          // HomeScreen sauber neu.
          // =======================================================
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: HomeScreen.routeName),
              builder: (context) => HomeScreen(
                hunt: hunt,
                huntProgress: huntProgress,
              ),
            ),
            (Route<dynamic> route) => route.isFirst,
          );
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
              builder: (_) => const AdminLoginScreen()
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'code_entry',
          child: ListTile(
            leading: Icon(Icons.keyboard_return_outlined),
            title: Text('Code eingeben'),
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
