// lib/features/clue/gps_navigation_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:clue_master/data/models/clue.dart'; // Passe den Import-Pfad ggf. an

class GpsNavigationScreen extends StatefulWidget {
  final Clue clue;

  const GpsNavigationScreen({super.key, required this.clue});

  @override
  State<GpsNavigationScreen> createState() => _GpsNavigationScreenState();
}

class _GpsNavigationScreenState extends State<GpsNavigationScreen> {
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassStream;

  double _distanceInMeters = double.infinity;
  double? _heading = 0; // Für die Kompass-Ausrichtung
  bool _isNearby = false;

  @override
  void initState() {
    super.initState();
    _startListeningToLocation();
    _startListeningToCompass();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _compassStream?.cancel();
    super.dispose();
  }

  void _startListeningToCompass() {
    // Nur starten, wenn das Event-Stream verfügbar ist
    if (FlutterCompass.events != null) {
      _compassStream = FlutterCompass.events!.listen((CompassEvent event) {
        if (mounted) { // Sicherstellen, dass das Widget noch im Baum ist
          setState(() {
            _heading = event.heading;
          });
        }
      });
    }
  }

  void _startListeningToLocation() async {
    // Deine bisherige Logik zum Starten des Location-Services bleibt größtenteils gleich.
    // Wichtig ist, dass die Berechtigungen etc. hier korrekt abgefragt werden.
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle den Fall, dass die Ortungsdienste deaktiviert sind
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle den Fall, dass die Berechtigung verweigert wurde
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Handle den Fall, dass die Berechtigung dauerhaft verweigert wurde
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Aktualisiert bei jeder Meter-Änderung
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null && widget.clue.latitude != null && widget.clue.longitude != null && mounted) {
        setState(() {
          _distanceInMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            widget.clue.latitude!,
            widget.clue.longitude!,
          );
          _isNearby = _distanceInMeters <= (widget.clue.radius ?? 15);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lade das Hintergrundbild nur, wenn ein Pfad vorhanden ist
    final backgroundImage = widget.clue.backgroundImagePath != null && widget.clue.backgroundImagePath!.isNotEmpty
        ? FileImage(File(widget.clue.backgroundImagePath!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clue.description ?? 'GPS-Navigation'),
        backgroundColor: Colors.transparent, // Transparent machen
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Lässt den Body hinter die AppBar rücken
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Das Hintergrundbild (wenn vorhanden)
          if (backgroundImage != null)
            Image(
              image: backgroundImage,
              fit: BoxFit.cover,
              // Dunkler Filter für bessere Lesbarkeit des Vordergrunds
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          
          // Wenn kein Bild da ist, ein Standard-Gradient
          if (backgroundImage == null)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              ),
            ),

          // 2. Die Kompassnadel
          Center(
            child: Transform.rotate(
              // Rotiert die Nadel basierend auf dem Kompass-Heading
              // Die Umrechnung in Bogenmaß (radians) ist wichtig
              angle: ((_heading ?? 0) * (pi / 180) * -1),
              child: Image.asset(
                'assets/images/compass_needle.png', // Pfad zur Kompassnadel-Grafik
                width: 250,
                height: 250,
              ),
            ),
          ),
          
          // 3. Die UI-Elemente (Distanz, Button etc.)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                 const Spacer(flex: 2),
                Text(
                  'Distanz zum Ziel',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    shadows: [const Shadow(blurRadius: 8, color: Colors.black87)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _distanceInMeters == double.infinity 
                      ? 'berechne...' 
                      : '${_distanceInMeters.toStringAsFixed(0)} Meter',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: _isNearby ? Colors.greenAccent : Colors.white,
                        fontWeight: FontWeight.w900,
                        shadows: [const Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                ),
                const Spacer(flex: 3), // Schiebt den unteren Teil nach unten
                if (_isNearby)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Hinweis freischalten'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      // Signalisiert der vorherigen Seite, dass das GPS-Rätsel gelöst ist
                      Navigator.pop(context, true); 
                    },
                  ),
                const SizedBox(height: 60), // Platz am unteren Rand
              ],
            ),
          ),
        ],
      ),
    );
  }
}