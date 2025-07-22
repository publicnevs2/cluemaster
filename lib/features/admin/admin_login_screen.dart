// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // NEU: Import für die Datumsformatierung.
import '../../core/services/clue_service.dart'; // NEU: Import für den Service.
import 'admin_dashboard_screen.dart';

// ============================================================
// SECTION: AdminLoginScreen Widget
// ============================================================
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

// ============================================================
// SECTION: State-Klasse
// ============================================================
class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // ============================================================
  // SECTION: State & Controller
  // ============================================================
  final TextEditingController _passwordController = TextEditingController();
  final ClueService _clueService = ClueService(); // NEU: Instanz des Service erstellen.
  String? _errorText;

  // Das feste Passwort wird entfernt, da es jetzt dynamisch geladen wird.
  // final String _adminPassword = 'admin123'; // ENTFERNT

  // ============================================================
  // SECTION: Logik
  // ============================================================

  /// Prüft das eingegebene Passwort gegen das gespeicherte und das Backup-Passwort.
  void _checkPassword() async {
    final enteredPassword = _passwordController.text.trim();

    // 1. Lade das aktuell in der Datei gespeicherte Admin-Passwort.
    final storedPassword = await _clueService.loadAdminPassword();

    // 2. Generiere das dynamische Backup-Passwort basierend auf dem heutigen Datum.
    final today = DateTime.now();
    final formattedDate = DateFormat('ddMMyyyy').format(today);
    final backupPassword = 'admin$formattedDate';
    
    print("DEBUG: Eingegeben: $enteredPassword, Gespeichert: $storedPassword, Backup: $backupPassword");

    // 3. Prüfe, ob die Eingabe mit einem der beiden gültigen Passwörter übereinstimmt.
    if (enteredPassword == storedPassword || enteredPassword == backupPassword) {
      // Bei Erfolg zum Dashboard navigieren.
      // pushReplacement verhindert, dass der Nutzer zum Login-Screen zurückkehren kann.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      // Bei Misserfolg eine Fehlermeldung anzeigen.
      setState(() {
        _errorText = 'Falsches Passwort';
      });
    }
  }

  // ============================================================
  // SECTION: UI-Aufbau (build-Methode)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Admin-Zugang',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true, // Versteckt die Passworteingabe.
              decoration: InputDecoration(
                labelText: 'Passwort eingeben',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
              // Ermöglicht das Absenden mit der Enter-Taste auf der Tastatur.
              onSubmitted: (_) => _checkPassword(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPassword,
              child: const Text('Einloggen'),
            ),
          ],
        ),
      ),
    );
  }
}
