import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineWidget extends StatelessWidget {
  final ScrollController controller;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const TimelineWidget({
    super.key,
    required this.controller,
    required this.selectedDate,
    required this.onDateSelected,
  });

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year);
    final lastDayOfYear = DateTime(now.year, 12, 31);
    final totalDays = lastDayOfYear.difference(firstDayOfYear).inDays + 1;
    final theme = Theme.of(context);

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalDays,
        itemBuilder: (context, index) {
          final date = firstDayOfYear.add(Duration(days: index));
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, now);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
                child: date.day == 1
                    ? Center(
                        child: Text(
                          DateFormat('MMM').format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    : null,
              ),
              GestureDetector(
                onTap: () {
                  onDateSelected(date);
                },
                child: Container(
                  width: 50,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    border: isToday && !isSelected
                        ? Border.all(
                            color: theme.colorScheme.onSurface,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? theme.colorScheme.surface
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.38,
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? theme.colorScheme.surface
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
