import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryHeader extends StatelessWidget {
  final DateTime selectedDate;
  final int activeCount;

  const SummaryHeader({
    super.key,
    required this.selectedDate,
    required this.activeCount,
  });

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                activeCount.toString(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MEDICATIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    _isToday(selectedDate)
                        ? 'SCHEDULED TODAY'
                        : 'SCHEDULED FOR ${DateFormat('MMM d').format(selectedDate).toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
