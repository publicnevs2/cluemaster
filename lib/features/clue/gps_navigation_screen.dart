import 'dart:async';
import 'package:clue_master/core/services/clue_service.dart';
import 'package:clue_master/core/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import 'clue_detail_screen.dart';

class GpsNavigationScreen extends StatefulWidget {
  final Hunt hunt;
  final Clue clue;

  const GpsNavigationScreen({super.key, required this.hunt, required this.clue});

  @override
  State<GpsNavigationScreen> createState() => _GpsNavigationScreenState();
}

class _GpsNavigationScreenState extends State<GpsNavigationScreen> {
  final ClueService _clueService = ClueService();
  final SoundService _soundService = SoundService();

  StreamSubscription<Position>? _positionStreamSubscription;
  String _statusMessage = 'Überprüfe GPS-Signal...';
  double? _distanceInMeters;

  @override
  void initState() {
    super.initState();
    _startGpsTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); // Wichtig: Stream beenden!
    _soundService.dispose();
    super.dispose();
  }

  Future<void> _startGpsTracking() async {
    // 1. Prüfen, ob der Standortdienst aktiviert ist
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _statusMessage = 'Bitte aktiviere die Standortermittlung (GPS).');
      return;
    }

    // 2. Berechtigungen prüfen und anfordern
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _statusMessage = 'Standort-Berechtigung wurde verweigert.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _statusMessage = 'Standort-Berechtigung wurde dauerhaft verweigert. Bitte in den App-Einstellungen ändern.');
      return;
    }

    // 3. Standort-Updates abonnieren
    setState(() => _statusMessage = 'Suche nach Ziel...');
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Update bei jeder Meter-Änderung
      ),
    ).listen((Position position) {
      if (!mounted) return;

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.clue.latitude!,
        widget.clue.longitude!,
      );

      setState(() {
        _distanceInMeters = distance;
        _statusMessage = 'Auf dem Weg zum Ziel...';
      });

      // 4. Prüfen, ob das Ziel erreicht wurde
      if (distance <= (widget.clue.radius ?? 20.0)) {
        _unlockClue();
      }
    });
  }

  Future<void> _unlockClue() async {
    // Stream stoppen, um mehrfaches Auslösen zu verhindern
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    if (!mounted || widget.clue.solved) return;

    // Feedback geben und Zustand aktualisieren
    Vibration.vibrate(duration: 500);
    _soundService.playSound(SoundEffect.success);
    widget.clue.solved = true;
    
    // Fortschritt speichern
    final allHunts = await _clueService.loadHunts();
    final huntIndex = allHunts.indexWhere((h) => h.name == widget.hunt.name);
    if (huntIndex != -1) {
      allHunts[huntIndex].clues[widget.clue.code] = widget.clue;
      await _clueService.saveHunts(allHunts);
    }
    
    // Zum Detailbildschirm weiterleiten, um die Belohnung anzuzeigen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ClueDetailScreen(hunt: widget.hunt, clue: widget.clue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigiere zu: ${widget.clue.code}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.explore_outlined, size: 120, color: Colors.amber),
              const SizedBox(height: 32),
              if (_distanceInMeters != null)
                Text(
                  '${_distanceInMeters!.toStringAsFixed(0)} Meter',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                )
              else
                const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _statusMessage,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
