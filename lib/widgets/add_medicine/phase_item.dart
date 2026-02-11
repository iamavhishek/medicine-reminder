import 'package:ausadhi_khau/models/medicine_schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PhaseItem extends StatelessWidget {
  final int phaseNumber;
  final MedicineSchedule schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PhaseItem({
    super.key,
    required this.phaseNumber,
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatScheduleSummary(MedicineSchedule s) {
    final String freq = s.frequency.toUpperCase();
    String details = '';
    if (s.frequency == 'weekly') {
      final names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      details = s.daysOfWeek.map((d) => names[d - 1]).join(',');
    } else if (s.frequency == 'monthly') {
      details = 'DAYS ${s.daysOfMonth.join(',')}';
    }
    return '$freq: $details';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              phaseNumber.toString(),
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PHASE PLAN • ${schedule.dosage.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  _formatScheduleSummary(schedule),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                ),
                Text(
                  '${DateFormat('MMM d').format(schedule.startDate)} - ${schedule.endDate != null ? DateFormat('MMM d, y').format(schedule.endDate!) : 'CONTINUOUS'}',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
