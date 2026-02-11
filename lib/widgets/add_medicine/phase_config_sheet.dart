import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_remainder_app/models/medicine_schedule.dart';
import 'package:medicine_remainder_app/widgets/add_medicine/day_selector.dart';
import 'package:medicine_remainder_app/widgets/add_medicine/frequency_selector.dart';
import 'package:medicine_remainder_app/widgets/add_medicine/time_selector.dart';

class PhaseConfigSheet extends StatefulWidget {
  final MedicineSchedule initialSchedule;

  const PhaseConfigSheet({super.key, required this.initialSchedule});

  @override
  State<PhaseConfigSheet> createState() => _PhaseConfigSheetState();
}

class _PhaseConfigSheetState extends State<PhaseConfigSheet> {
  final _dosageController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _frequency = 'daily';
  final List<int> _selectedDaysOfMonth = [];
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  final List<TimeOfDay> _selectedTimes = [];

  @override
  void initState() {
    super.initState();
    _dosageController.text = widget.initialSchedule.dosage;
    _startDate = widget.initialSchedule.startDate;
    _endDate = widget.initialSchedule.endDate;
    _frequency = widget.initialSchedule.frequency;
    _selectedDaysOfMonth.addAll(widget.initialSchedule.daysOfMonth);
    for (int d in widget.initialSchedule.daysOfWeek) {
      if (d > 0 && d <= 7) _selectedDays[d - 1] = true;
    }
    for (String t in widget.initialSchedule.times) {
      final parts = t.split(':');
      _selectedTimes.add(
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'NEXT PHASE CONFIG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _dosageController,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                labelText: 'DOSAGE',
                labelStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                border: const UnderlineInputBorder(),
                prefixIcon: Icon(
                  Icons.straighten,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDateButton(
                    context,
                    'Start',
                    _startDate,
                    (d) => setState(() => _startDate = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateButton(
                    context,
                    'End',
                    _endDate,
                    (d) => setState(() => _endDate = d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FrequencySelector(
              selectedFrequency: _frequency,
              onFrequencyChanged: (f) => setState(() => _frequency = f),
            ),
            const SizedBox(height: 16),
            if (_frequency == 'daily')
              Text(
                'Notifications will fire every day at the times selected.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            if (_frequency == 'weekly')
              WeeklyDaySelector(
                isSelected: _selectedDays,
                onDayToggled: (index) => setState(
                  () => _selectedDays[index] = !_selectedDays[index],
                ),
              ),
            if (_frequency == 'monthly')
              MonthlyDaySelector(
                selectedDays: _selectedDaysOfMonth,
                onDayToggled: (day) => setState(() {
                  if (_selectedDaysOfMonth.contains(day)) {
                    _selectedDaysOfMonth.remove(day);
                  } else {
                    _selectedDaysOfMonth.add(day);
                  }
                }),
              ),
            const SizedBox(height: 32),
            TimeSelector(
              selectedTimes: _selectedTimes,
              onTimeAdded: (t) => setState(() => _selectedTimes.add(t)),
              onTimeRemoved: (t) => setState(() => _selectedTimes.remove(t)),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'CONFIRM PHASE',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(
    BuildContext context,
    String label,
    DateTime? date,
    Function(DateTime) onPicked,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (d != null) onPicked(d);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date == null
                  ? 'SELECT'
                  : DateFormat('MMM dd, yyyy').format(date).toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_dosageController.text.isEmpty ||
        _selectedTimes.isEmpty ||
        _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_frequency == 'weekly' && _selectedDays.every((day) => !day)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    if (_frequency == 'monthly' && _selectedDaysOfMonth.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day of month'),
        ),
      );
      return;
    }
    final days = <int>[];
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) days.add(i + 1);
    }

    Navigator.pop(
      context,
      MedicineSchedule(
        dosage: _dosageController.text,
        times: _selectedTimes
            .map((t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}')
            .toList(),
        frequency: _frequency,
        daysOfWeek: days,
        daysOfMonth: List.from(_selectedDaysOfMonth),
        startDate: _startDate!,
        endDate: _endDate,
      ),
    );
  }
}
