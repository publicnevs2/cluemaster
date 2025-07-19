import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Wir wandeln das Widget in ein "StatefulWidget" um, damit es sich einen Zustand merken kann.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // Diese Variable ist unser "Gedächtnis". Am Anfang ist sie `false`.
  bool _isScanCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR-Code scannen')),
      body: MobileScanner(
        onDetect: (capture) {
          // Wir prüfen, ob wir nicht schon einen Code gescannt haben.
          if (!_isScanCompleted) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String? code = barcodes.first.rawValue;
              if (code != null && code.isNotEmpty) {
                // WICHTIG: Wir setzen die Variable sofort auf `true`.
                // Damit wird jeder weitere Scan in dieser Sitzung ignoriert.
                setState(() {
                  _isScanCompleted = true;
                });
                
                // Jetzt geben wir den Code sicher nur ein einziges Mal zurück.
                Navigator.pop(context, code);
              }
            }
          }
        },
      ),
    );
  }
}