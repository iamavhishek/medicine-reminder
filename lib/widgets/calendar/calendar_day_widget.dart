import 'package:flutter/material.dart';
import 'package:medicine_remainder_app/models/medicine.dart';

class CalendarDayWidget extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final List<Medicine> medicines;
  final bool isDesktop;
  final VoidCallback onTap;

  const CalendarDayWidget({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.medicines,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: isToday && !isSelected
                ? Border.all(color: theme.colorScheme.onSurface, width: 2)
                : Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
          ),
          padding: EdgeInsets.all(isDesktop ? 12 : 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date.day.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: isDesktop ? 16 : 13,
                  color: isSelected
                      ? theme.colorScheme.surface
                      : theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (medicines.isNotEmpty)
                Row(
                  children: [
                    ...medicines
                        .take(isDesktop ? 3 : 4)
                        .map(
                          (m) => Container(
                            width: isDesktop ? 6 : 4,
                            height: isDesktop ? 6 : 4,
                            margin: EdgeInsets.only(right: isDesktop ? 2 : 1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.surface.withValues(
                                      alpha: 0.7,
                                    )
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.38,
                                    ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    if (medicines.length > (isDesktop ? 3 : 4))
                      Text(
                        '+',
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.surface.withValues(alpha: 0.7)
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.38,
                                ),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
