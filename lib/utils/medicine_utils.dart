import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_remainder_app/models/medicine.dart';
import 'package:medicine_remainder_app/models/medicine_schedule.dart';

class MedicineUtils {
  static bool isDateInBaseSchedule(Medicine m, DateTime date) {
    final start = DateTime(
      m.startDate.year,
      m.startDate.month,
      m.startDate.day,
    );
    final end = m.endDate == null
        ? null
        : DateTime(
            m.endDate!.year,
            m.endDate!.month,
            m.endDate!.day,
            23,
            59,
            59,
          );
    return !date.isBefore(start) && (end == null || !date.isAfter(end));
  }

  static bool isScheduleActive(MedicineSchedule s, DateTime now) {
    final start = DateTime(
      s.startDate.year,
      s.startDate.month,
      s.startDate.day,
    );
    final end = s.endDate == null
        ? null
        : DateTime(
            s.endDate!.year,
            s.endDate!.month,
            s.endDate!.day,
            23,
            59,
            59,
          );

    return !now.isBefore(start) && (end == null || !now.isAfter(end));
  }

  static List<Medicine> getMedicinesForDate(
    List<Medicine> medicines,
    DateTime date,
  ) {
    return medicines.where((m) {
      bool hasActivePhase = false;
      if (m.schedules.isNotEmpty) {
        hasActivePhase = m.schedules.any((s) => isScheduleActive(s, date));
      } else {
        hasActivePhase = isDateInBaseSchedule(m, date);
      }

      if (!hasActivePhase) return false;

      final weekday = date.weekday;
      final dayOfMonth = date.day;

      String freq = m.frequency;
      List<int> dow = m.daysOfWeek;
      List<int> dom = m.daysOfMonth;

      if (m.schedules.isNotEmpty) {
        final phase = m.schedules.firstWhere(
          (s) => isScheduleActive(s, date),
          orElse: () => m.schedules.first,
        );
        freq = phase.frequency;
        dow = phase.daysOfWeek;
        dom = phase.daysOfMonth;
      }

      if (freq == 'weekly') {
        return dow.contains(weekday);
      } else if (freq == 'monthly') {
        return dom.isEmpty
            ? date.day == m.startDate.day
            : dom.contains(dayOfMonth);
      } else if (freq == 'yearly') {
        return date.month == m.startDate.month && date.day == m.startDate.day;
      } else if (freq == 'daily') {
        return true;
      }
      return true;
    }).toList();
  }

  static bool isSkipped(Medicine medicine, DateTime date) {
    return medicine.skippedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  static bool isManuallyEnabled(Medicine medicine, DateTime date) {
    return medicine.manualActiveDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  static bool isEffectivelyActive(Medicine medicine, DateTime date) {
    if (medicine.isActive) {
      return !isSkipped(medicine, date);
    }
    return isManuallyEnabled(medicine, date);
  }

  static String formatSchedule(Medicine medicine) {
    if (medicine.schedules.isNotEmpty) {
      final now = DateTime.now();
      final current = medicine.schedules.firstWhere(
        (s) => isScheduleActive(s, now),
        orElse: () => medicine.schedules.first,
      );
      return '${formatSingleSchedule(current.frequency, current.daysOfWeek, current.daysOfMonth, current.startDate)} (Phase Plan)';
    }
    return formatSingleSchedule(
      medicine.frequency,
      medicine.daysOfWeek,
      medicine.daysOfMonth,
      medicine.startDate,
    );
  }

  static String formatSingleSchedule(
    String frequency,
    List<int> daysOfWeek,
    List<int> daysOfMonth,
    DateTime startDate,
  ) {
    if (frequency == 'daily') {
      return 'Daily';
    } else if (frequency == 'weekly') {
      if (daysOfWeek.length == 7) return 'Daily';
      if (daysOfWeek.length == 5 &&
          daysOfWeek.contains(1) &&
          daysOfWeek.contains(5)) {
        return 'Weekdays';
      }
      final names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return daysOfWeek.map((d) => names[d - 1]).join(', ');
    } else if (frequency == 'monthly') {
      return 'Monthly (Days: ${daysOfMonth.join(', ')})';
    } else {
      return 'Yearly (${DateFormat('MMM dd').format(startDate)})';
    }
  }

  static String getMedicineTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'pill':
        return 'PILL';
      case 'syrup':
      case 'liquid':
        return 'SYRUP';
      case 'syringe':
      case 'injection':
        return 'INJECT';
      case 'drops':
        return 'DROPS';
      case 'ointment':
      case 'cream':
        return 'CREAM';
      default:
        return 'MEDICINE';
    }
  }

  static String formatTimeOfDayString(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:$minute $period';
  }

  static IconData getMedicineIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pill':
      case 'tablet':
        return Icons.medication_rounded;
      case 'syrup':
      case 'liquid':
      case 'drops':
        return Icons.water_drop_rounded;
      case 'syringe':
      case 'injection':
        return Icons.vaccines_rounded;
      case 'ointment':
      case 'cream':
        return Icons.brush_rounded;
      default:
        return Icons.medication_outlined;
    }
  }

  static Medicine? findNextDose(
    List<Medicine> medicines,
    DateTime selectedDate,
  ) {
    final activeOnly = medicines
        .where((m) => isEffectivelyActive(m, selectedDate))
        .toList();
    if (activeOnly.isEmpty) return null;
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    Medicine? next;
    int minDiff = 24 * 60;

    for (var m in activeOnly) {
      final times = m.schedules.isNotEmpty
          ? m.schedules
                .firstWhere(
                  (s) => isScheduleActive(s, now),
                  orElse: () => m.schedules.first,
                )
                .times
          : m.times;

      for (var timeStr in times) {
        final parts = timeStr.split(':');
        final t = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        final diff = t - currentTime;
        if (diff > 0 && diff < minDiff) {
          minDiff = diff;
          next = m;
        }
      }
    }
    return next;
  }
}
