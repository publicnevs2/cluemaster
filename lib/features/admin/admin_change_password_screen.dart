// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';

// ============================================================
// SECTION: AdminChangePasswordScreen Widget
// ============================================================
class AdminChangePasswordScreen extends StatefulWidget {
  const AdminChangePasswordScreen({super.key});

  @override
  State<AdminChangePasswordScreen> createState() =>
      _AdminChangePasswordScreenState();
}

// ============================================================
// SECTION: State-Klasse
// ============================================================
class _AdminChangePasswordScreenState
    extends State<AdminChangePasswordScreen> {
  // ============================================================
  // SECTION: State & Controller
  // ============================================================

  // GlobalKey zur Validierung des Formulars.
  final _formKey = GlobalKey<FormState>();

  // Controller für die Eingabefelder.
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Instanz des Services, um das Passwort zu speichern und zu laden.
  final _clueService = ClueService();

  // ============================================================
  // SECTION: Logik
  // ============================================================

  /// Speichert das neue Passwort, wenn alle Validierungen erfolgreich sind.
  Future<void> _changePassword() async {
    // 1. Führe die synchrone Formularvalidierung durch (neues Passwort, Bestätigung etc.).
    if (!_formKey.currentState!.validate()) {
      return; // Beenden, wenn das Formular ungültig ist.
    }

    // 2. Lade das gespeicherte Passwort.
    final storedPassword = await _clueService.loadAdminPassword();
    final currentPassword = _currentPasswordController.text.trim();

    // 3. Prüfe, ob das eingegebene aktuelle Passwort korrekt ist.
    if (currentPassword != storedPassword) {
      // Zeige eine Fehlermeldung an, wenn das Passwort falsch ist.
      // Der 'mounted'-Check ist eine Sicherheitsmaßnahme in async-Methoden.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Das aktuelle Passwort ist nicht korrekt.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Beenden, wenn das Passwort nicht stimmt.
    }

    // 4. Wenn alles korrekt ist, speichere das neue Passwort.
    await _clueService.saveAdminPassword(_newPasswordController.text.trim());

    // Zeige eine Erfolgsmeldung an und schließe den Bildschirm.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Passwort erfolgreich geändert!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  // ============================================================
  // SECTION: UI-Aufbau (build-Methode)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin-Passwort ändern')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Eingabefeld für das aktuelle Passwort
            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Aktuelles Passwort'),
              // Der Validator prüft jetzt nur noch, ob das Feld leer ist.
              // Die eigentliche Passwort-Prüfung erfolgt in _changePassword.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib das aktuelle Passwort ein.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Eingabefeld für das neue Passwort
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Neues Passwort'),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Das Passwort muss mindestens 6 Zeichen lang sein.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Eingabefeld zur Bestätigung des neuen Passworts
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Neues Passwort bestätigen'),
              validator: (value) {
                if (value != _newPasswordController.text) {
                  return 'Die Passwörter stimmen nicht überein.';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Speicher-Button
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Passwort speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
