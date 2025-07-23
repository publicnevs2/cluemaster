// lib/core/services/sound_service.dart

import 'package:just_audio/just_audio.dart';

// Enum MUSS außerhalb der Klasse deklariert werden.
enum SoundEffect {
  success,
  failure,
  clueUnlocked,
  buttonClick,
  appStart
}

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  // Die Map, die unsere Enum-Werte auf die Dateinamen abbildet.
  final Map<SoundEffect, String> _soundFiles = {
    SoundEffect.success: 'assets/audio/success.mp3',
    SoundEffect.failure: 'assets/audio/failure.mp3',
    SoundEffect.clueUnlocked: 'assets/audio/clue_unlocked.mp3',
    SoundEffect.buttonClick: 'assets/audio/button_click.mp3',
    SoundEffect.appStart: 'assets/audio/app_start.mp3',
  };

  Future<void> playSound(SoundEffect sound) async {
    try {
      final assetPath = _soundFiles[sound];
      if (assetPath != null) {
        if (_player.playing) {
          await _player.stop();
        }
        await _player.setAsset(assetPath);
        await _player.play();
      }
    } catch (e) {
      // Dieser Print-Befehl ist nützlich für die Fehlersuche.
      // ignore: avoid_print
      print("Fehler beim Abspielen von Sound '$sound': $e");
    }
  }

  void dispose() {
    _player.dispose();
  }
}