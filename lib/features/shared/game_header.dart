import 'package:flutter/material.dart';

class GameHeader extends StatelessWidget implements PreferredSizeWidget {
  final String huntTitle;
  final Duration elapsedTime;
  final int currentClueIndex;
  final int totalClues;

  const GameHeader({
    super.key,
    required this.huntTitle,
    required this.elapsedTime,
    required this.currentClueIndex,
    required this.totalClues,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        '${elapsedTime.inHours.toString().padLeft(2, '0')}:${(elapsedTime.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}';

    // Wir wrappen alles in eine AppBar, um die volle Kontrolle zu haben
    return AppBar(
      // Hiermit verhindern wir den "Zurück"-Pfeil
      automaticallyImplyLeading: false, 
      backgroundColor: Colors.black.withOpacity(0.7),
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                huntTitle,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'SpecialElite',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Station: $currentClueIndex/$totalClues',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'SpecialElite',
                        ),
                      ),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}