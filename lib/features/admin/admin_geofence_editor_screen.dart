// lib/features/admin/admin_geofence_editor_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/hunt.dart';

class AdminGeofenceEditorScreen extends StatefulWidget {
  final GeofenceTrigger? existingTrigger;
  final Hunt hunt;
  final Function(GeofenceTrigger) onSave;
  final List<String> existingTriggerIds;

  const AdminGeofenceEditorScreen({
    super.key,
    this.existingTrigger,
    required this.hunt,
    required this.onSave,
    required this.existingTriggerIds,
  });

  @override
  State<AdminGeofenceEditorScreen> createState() =>
      _AdminGeofenceEditorScreenState();
}

class _AdminGeofenceEditorScreenState extends State<AdminGeofenceEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _idController;
  late TextEditingController _messageController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _radiusController;
  String? _selectedRewardItemId;
  bool _isFetchingLocation = false;

  bool get _isEditing => widget.existingTrigger != null;

  @override
  void initState() {
    super.initState();
    final trigger = widget.existingTrigger;
    // Generiert nur eine neue ID, wenn ein neuer Trigger erstellt wird
    _idController = TextEditingController(text: trigger?.id ?? _uuid.v4().substring(0, 8));
    _messageController = TextEditingController(text: trigger?.message ?? '');
    _latitudeController =
        TextEditingController(text: trigger?.latitude.toString() ?? '');
    _longitudeController =
        TextEditingController(text: trigger?.longitude.toString() ?? '');
    _radiusController =
        TextEditingController(text: trigger?.radius.toString() ?? '20');
    _selectedRewardItemId = trigger?.rewardItemId;
  }

  @override
  void dispose() {
    _idController.dispose();
    _messageController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      var permission = await Permission.location.request();
      if (permission.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _latitudeController.text = position.latitude.toString();
          _longitudeController.text = position.longitude.toString();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Standort-Berechtigung wurde verweigert.'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Standort konnte nicht abgerufen werden: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final trigger = GeofenceTrigger(
        id: _idController.text.trim(),
        message: _messageController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
        radius: double.parse(_radiusController.text.trim()),
        rewardItemId: _selectedRewardItemId,
        hasBeenTriggered: widget.existingTrigger?.hasBeenTriggered ?? false,
      );
      widget.onSave(trigger);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Trigger bearbeiten' : 'Neuer Trigger'),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.save))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ============================================================
            // GEÄNDERT: ID-Feld ist jetzt bearbeitbar und wird validiert
            // ============================================================
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Eindeutige ID',
                hintText: 'z.B. PARK_EINGANG (keine Leerzeichen)',
              ),
              validator: (value) {
                final id = value?.trim() ?? '';
                if (id.isEmpty) {
                  return 'Die ID darf nicht leer sein.';
                }
                if (id.contains(' ')) {
                  return 'Die ID darf keine Leerzeichen enthalten.';
                }
                // Prüft auf Einzigartigkeit, erlaubt aber die eigene ID bei der Bearbeitung
                final otherIds = List<String>.from(widget.existingTriggerIds);
                if (_isEditing) {
                  otherIds.remove(widget.existingTrigger!.id);
                }
                if (otherIds.contains(id)) {
                  return 'Diese ID wird bereits verwendet.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Nachricht für den Spieler',
                hintText: 'z.B. Du hast eine versteckte Notiz gefunden!',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Nachricht ist ein Pflichtfeld.' : null,
            ),
            const SizedBox(height: 24),
            Text('Standort & Radius',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Breitengrad (Latitude)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) =>
                  (v == null || v.isEmpty || double.tryParse(v) == null)
                      ? 'Breitengrad erforderlich'
                      : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: 'Längengrad (Longitude)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) =>
                  (v == null || v.isEmpty || double.tryParse(v) == null)
                      ? 'Längengrad erforderlich'
                      : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _radiusController,
              decoration: const InputDecoration(
                  labelText: 'Radius in Metern', hintText: 'z.B. 20'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
                  (v == null || v.isEmpty || int.tryParse(v) == null)
                      ? 'Radius erforderlich'
                      : null,
            ),
            const SizedBox(height: 16),
            Center(
              child: _isFetchingLocation
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.my_location),
                      label: const Text('Aktuellen Standort eintragen'),
                      onPressed: _getCurrentLocation,
                    ),
            ),
            const SizedBox(height: 24),
            Text('Optionale Belohnung',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            const SizedBox(height: 16),
            _buildItemDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDropdown() {
    final items = widget.hunt.items.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final dropdownItems = [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Kein Item', style: TextStyle(fontStyle: FontStyle.italic)),
      ),
      ...items.map((item) {
        return DropdownMenuItem<String>(
          value: item.id,
          child: Text(item.name),
        );
      }),
    ];

    return DropdownButtonFormField<String>(
      value: _selectedRewardItemId,
      items: dropdownItems,
      onChanged: (itemId) {
        setState(() {
          _selectedRewardItemId = itemId;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Belohnungs-Item',
        hintText: 'Spieler erhält dieses Item, wenn der Trigger auslöst',
      ),
    );
  }
}
