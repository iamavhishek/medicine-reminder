import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final List<TimeOfDay> selectedTimes;
  final Function(TimeOfDay) onTimeAdded;
  final Function(TimeOfDay) onTimeRemoved;

  const TimeSelector({
    super.key,
    required this.selectedTimes,
    required this.onTimeAdded,
    required this.onTimeRemoved,
  });

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : hour;
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REMINDER TIMES',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 10,
            letterSpacing: 1,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...selectedTimes.map((time) {
              return Chip(
                label: Text(
                  _formatTimeOfDay(time),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onDeleted: () => onTimeRemoved(time),
                deleteIconColor: theme.colorScheme.onSurface,
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.03,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              );
            }),
            ActionChip(
              avatar: Icon(
                Icons.add,
                size: 16,
                color: theme.colorScheme.onPrimary,
              ),
              label: Text(
                'ADD TIME',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onPrimary,
                  letterSpacing: 1,
                ),
              ),
              onPressed: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  onTimeAdded(pickedTime);
                }
              },
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
