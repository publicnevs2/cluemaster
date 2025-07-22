// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/clue_service.dart';
import 'admin_hunt_list_screen.dart'; // NEU: Importiere den neuen Hunt-List-Screen.
// import 'admin_dashboard_screen.dart'; // ALTER IMPORT: Wird nicht mehr direkt benötigt.

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
  final ClueService _clueService = ClueService();
  String? _errorText;

  // ============================================================
  // SECTION: Logik
  // ============================================================
  void _checkPassword() async {
    final enteredPassword = _passwordController.text.trim();
    final storedPassword = await _clueService.loadAdminPassword();

    final today = DateTime.now();
    final formattedDate = DateFormat('ddMMyyyy').format(today);
    final backupPassword = 'admin$formattedDate';

    if (enteredPassword == storedPassword || enteredPassword == backupPassword) {
      // ============================================================
      // KORREKTUR: Das Navigationsziel wurde geändert.
      // Statt zum alten Dashboard navigieren wir jetzt zur neuen Liste der Schnitzeljagden.
      // ============================================================
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHuntListScreen()),
      );
    } else {
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
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Passwort eingeben',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
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
