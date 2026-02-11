import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medicine_remainder_app/blocs/medicine/medicine_bloc.dart';
import 'package:medicine_remainder_app/blocs/medicine/medicine_state.dart';
import 'package:medicine_remainder_app/utils/medicine_utils.dart';
import 'package:medicine_remainder_app/widgets/calendar/calendar_day_widget.dart';
import 'package:medicine_remainder_app/widgets/calendar/day_detail_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildCalendarView(context),
          ),
          if (isDesktop)
            Container(
              width: 380,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: _buildDayDetails(context),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_medicine_calendar',
        onPressed: () {
          context.push('/add', extra: _selectedDate ?? DateTime.now());
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'ADD MEDICINE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: isDesktop ? 48 : 24,
        right: isDesktop ? 48 : 24,
        bottom: 24,
        top: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDesktop),
          const SizedBox(height: 32),
          _buildMonthGrid(),
          if (!isDesktop) ...[
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            _buildDayDetails(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COLLECTIVE',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                fontWeight: FontWeight.w800,
                fontSize: isDesktop ? 12 : 10,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM yyyy').format(_focusedDate).toUpperCase(),
              style: TextStyle(
                fontSize: isDesktop ? 32 : 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => setState(
                () => _focusedDate = DateTime(
                  _focusedDate.year,
                  _focusedDate.month - 1,
                ),
              ),
              icon: const Icon(Icons.chevron_left),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                padding: EdgeInsets.all(isDesktop ? 12 : 8),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => setState(
                () => _focusedDate = DateTime(
                  _focusedDate.year,
                  _focusedDate.month + 1,
                ),
              ),
              icon: const Icon(Icons.chevron_right),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                padding: EdgeInsets.all(isDesktop ? 12 : 8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthGrid() {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDate.year,
      _focusedDate.month,
    );
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month);
    final weekdayOffset = firstDayOfMonth.weekday - 1;

    return BlocBuilder<MedicineBloc, MedicineState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildWeekdayLabels(context),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: isDesktop ? 1.0 : 0.7,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dayNumber = index - weekdayOffset + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox();
                }

                final date = DateTime(
                  _focusedDate.year,
                  _focusedDate.month,
                  dayNumber,
                );
                return CalendarDayWidget(
                  date: date,
                  isSelected: _isSameDay(date, _selectedDate),
                  isToday: _isSameDay(date, DateTime.now()),
                  medicines: MedicineUtils.getMedicinesForDate(
                    state.medicines,
                    date,
                  ),
                  isDesktop: isDesktop,
                  onTap: () => setState(() => _selectedDate = date),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekdayLabels(BuildContext context) {
    final theme = Theme.of(context);
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDayDetails(BuildContext context) {
    if (_selectedDate == null) return const SizedBox();
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return BlocBuilder<MedicineBloc, MedicineState>(
      builder: (context, state) {
        final medicines = MedicineUtils.getMedicinesForDate(
          state.medicines,
          _selectedDate!,
        );
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMMM d').format(_selectedDate!).toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'DAY SCHEDULE',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            if (medicines.isEmpty)
              Column(
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Text(
                      'NO MEDICINES SCHEDULED',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.26,
                        ),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              )
            else
              ...medicines.map((m) => DayDetailCard(medicine: m)),
          ],
        );

        if (!isDesktop) return content;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: content,
        );
      },
    );
  }
}
