import 'package:flutter/material.dart';

class FrequencySelector extends StatelessWidget {
  final String selectedFrequency;
  final Function(String) onFrequencyChanged;

  const FrequencySelector({
    super.key,
    required this.selectedFrequency,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FREQUENCY',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 10,
            letterSpacing: 1,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildFrequencyOption(context, 'daily', 'DAILY'),
            const SizedBox(width: 8),
            _buildFrequencyOption(context, 'weekly', 'WEEKLY'),
            const SizedBox(width: 8),
            _buildFrequencyOption(context, 'monthly', 'MONTHLY'),
            const SizedBox(width: 8),
            _buildFrequencyOption(context, 'yearly', 'YEARLY'),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequencyOption(
    BuildContext context,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    final isSelected = selectedFrequency == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onFrequencyChanged(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
