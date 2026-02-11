import 'package:flutter/material.dart';

class MedicineNameField extends StatelessWidget {
  final TextEditingController controller;

  const MedicineNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'MEDICINE NAME',
        labelStyle: TextStyle(
          fontSize: 10,
          letterSpacing: 1,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
        ),
        hintText: 'e.g., Paracetamol',
        border: const UnderlineInputBorder(),
        prefixIcon: Icon(
          Icons.drive_file_rename_outline,
          color: theme.colorScheme.onSurface,
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}

class DosageField extends StatelessWidget {
  final TextEditingController controller;

  const DosageField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'DOSAGE',
        labelStyle: TextStyle(
          fontSize: 10,
          letterSpacing: 1,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
        ),
        hintText: 'e.g., 1 tablet',
        border: const UnderlineInputBorder(),
        prefixIcon: Icon(
          Icons.straighten_outlined,
          color: theme.colorScheme.onSurface,
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}

class NotesField extends StatelessWidget {
  final TextEditingController controller;

  const NotesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: 3,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'NOTES (OPTIONAL)',
        labelStyle: TextStyle(
          fontSize: 10,
          letterSpacing: 1,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
        ),
        hintText: 'e.g., Take after meals',
        border: const OutlineInputBorder(),
      ),
    );
  }
}
