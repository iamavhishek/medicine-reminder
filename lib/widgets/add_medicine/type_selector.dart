import 'package:flutter/material.dart';
import 'package:medicine_remainder_app/utils/medicine_utils.dart';

class TypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeSelected;

  const TypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEDICINE TYPE',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTypeOption(context, 'pill', Icons.medication_rounded),
            _buildTypeOption(context, 'syrup', Icons.coffee_rounded),
            _buildTypeOption(context, 'syringe', Icons.vaccines_rounded),
            _buildTypeOption(context, 'drops', Icons.water_drop_rounded),
            _buildTypeOption(context, 'ointment', Icons.brush_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeOption(BuildContext context, String value, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = selectedType == value;
    return GestureDetector(
      onTap: () {
        onTypeSelected(value);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            MedicineUtils.getMedicineTypeLabel(value),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
