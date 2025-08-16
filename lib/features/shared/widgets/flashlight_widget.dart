// lib/features/shared/widgets/flashlight_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class FlashlightWidget extends StatefulWidget {
  const FlashlightWidget({super.key});

  @override
  State<FlashlightWidget> createState() => _FlashlightWidgetState();
}

class _FlashlightWidgetState extends State<FlashlightWidget> {
  bool _isFlashOn = false;
  double _batteryLevel = 1.0; // 1.0 = 100%
  Timer? _batteryDrainTimer;
  bool _isTorchAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkTorchAvailability();
  }

  Future<void> _checkTorchAvailability() async {
    try {
      final isAvailable = await TorchLight.isTorchAvailable();
      if (mounted) {
        setState(() {
          _isTorchAvailable = isAvailable;
        });
      }
    } on Exception catch (_) {
      _showErrorDialog('Taschenlampe konnte nicht initialisiert werden.');
    }
  }

  void _toggleFlashlight() {
    if (!_isTorchAvailable) {
      _showErrorDialog('Auf diesem Gerät ist keine Taschenlampe verfügbar.');
      return;
    }

    if (_batteryLevel <= 0 && !_isFlashOn) {
      _showErrorDialog('Die Batterie der Taschenlampe ist leer!');
      return;
    }

    setState(() {
      _isFlashOn = !_isFlashOn;
      if (_isFlashOn) {
        _turnFlashOn();
        _startBatteryDrain();
      } else {
        _turnFlashOff();
        _stopBatteryDrain();
      }
    });
  }

  void _turnFlashOn() {
    try {
      TorchLight.enableTorch();
    } on Exception catch (_) {
      _showErrorDialog('Taschenlampe konnte nicht aktiviert werden.');
      setState(() => _isFlashOn = false);
    }
  }

  void _turnFlashOff() {
    try {
      TorchLight.disableTorch();
    } on Exception catch (_) {
      // Fehler beim Ausschalten ist weniger kritisch
    }
  }

  void _startBatteryDrain() {
    _batteryDrainTimer?.cancel();
    // Batterie hält ca. 5 Minuten (300 Sekunden)
    _batteryDrainTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _batteryLevel -= 0.01; // 1% pro 3 Sekunden
          if (_batteryLevel <= 0) {
            _batteryLevel = 0;
            _isFlashOn = false;
            _turnFlashOff();
            timer.cancel();
          }
        });
      }
    });
  }

  void _stopBatteryDrain() {
    _batteryDrainTimer?.cancel();
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _turnFlashOff();
    _batteryDrainTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            _isFlashOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
            size: 100,
            color: _isFlashOn ? Colors.yellow[400] : Colors.grey[600],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _toggleFlashlight,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFlashOn ? Colors.grey[800] : Colors.amber,
              foregroundColor: _isFlashOn ? Colors.white : Colors.black,
              minimumSize: const Size(200, 60),
              shape: const StadiumBorder(),
            ),
            child: Text(
              _isFlashOn ? 'AUSSCHALTEN' : 'EINSCHALTEN',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          _buildBatteryIndicator(),
        ],
      ),
    );
  }

  Widget _buildBatteryIndicator() {
    return Column(
      children: [
        Text(
          'Batterie: ${(_batteryLevel * 100).toStringAsFixed(0)}%',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _batteryLevel,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(
            _batteryLevel > 0.5
                ? Colors.greenAccent
                : _batteryLevel > 0.2
                    ? Colors.orangeAccent
                    : Colors.redAccent,
          ),
          minHeight: 10,
        ),
      ],
    );
  }
}
