// lib/features/admin/widgets/clue_basic_info_section.dart

import 'package:flutter/material.dart';
import '../../../data/models/hunt.dart';

class ClueBasicInfoSection extends StatelessWidget {
  final TextEditingController codeController;
  final String? codeToEdit;
  final List<String> existingCodes;
  final String? selectedRequiredItemId;
  final Hunt hunt;
  final Function(String?) onRequiredItemChanged;

  const ClueBasicInfoSection({
    super.key,
    required this.codeController,
    this.codeToEdit,
    required this.existingCodes,
    this.selectedRequiredItemId,
    required this.hunt,
    required this.onRequiredItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basis-Informationen',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: codeController,
          decoration: const InputDecoration(labelText: 'Eindeutiger Code der Station'),
          validator: (value) {
            final code = value?.trim() ?? '';
            if (code.isEmpty) return 'Der Code ist ein Pflichtfeld.';
            if (codeToEdit == null && existingCodes.contains(code)) {
              return 'Dieser Code existiert bereits.';
            }
            if (codeToEdit != null && code != codeToEdit && existingCodes.contains(code)) {
              return 'Dieser Code existiert bereits.';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        _buildItemDropdown(
          label: 'Benötigtes Item (optional)',
          hint: 'Spieler muss dieses Item besitzen, um den Inhalt zu sehen',
          currentValue: selectedRequiredItemId,
          onChanged: onRequiredItemChanged,
        ),
      ],
    );
  }

  Widget _buildItemDropdown({
    required String label,
    required String hint,
    required String? currentValue,
    required ValueChanged<String?> onChanged,
  }) {
    final items = hunt.items.values.toList()
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
      value: currentValue,
      items: dropdownItems,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
