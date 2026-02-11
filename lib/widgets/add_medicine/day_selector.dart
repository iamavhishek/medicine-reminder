import 'package:flutter/material.dart';

class WeeklyDaySelector extends StatelessWidget {
  final List<bool> isSelected;
  final Function(int) onDayToggled;

  const WeeklyDaySelector({
    super.key,
    required this.isSelected,
    required this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ToggleButtons(
          borderRadius: BorderRadius.circular(100),
          splashColor: Colors.transparent,
          constraints: BoxConstraints(
            minWidth: (constraints.maxWidth - 40) / 7,
            minHeight: 40,
          ),
          isSelected: isSelected,
          onPressed: (index) {
            onDayToggled(index);
          },
          children: const [
            Text(
              'M',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              'T',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              'W',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              'T',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              'F',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              'S',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              'S',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }
}

class MonthlyDaySelector extends StatelessWidget {
  final List<int> selectedDays;
  final Function(int) onDayToggled;

  const MonthlyDaySelector({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(31, (index) {
        final day = index + 1;
        final isSelected = selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            onDayToggled(day);
          },
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        );
      }),
    );
  }
}
