import 'package:flutter/material.dart';
import 'package:medicine_remainder_app/models/medicine.dart';

class NextDoseHero extends StatelessWidget {
  final Medicine medicine;
  final String nextTimeStr;
  final String medicineTypeLabel;

  const NextDoseHero({
    super.key,
    required this.medicine,
    required this.nextTimeStr,
    required this.medicineTypeLabel,
  });

  String _formatTimeOfDayString(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'UPCOMING',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Text(
                _formatTimeOfDayString(nextTimeStr),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            medicine.name.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$medicineTypeLabel • ${medicine.dosage.toUpperCase()} • ${medicine.takeWithFood ? 'TAKE AFTER MEAL' : 'ON EMPTY STOMACH'}',
            style: TextStyle(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
