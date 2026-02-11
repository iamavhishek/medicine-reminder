import 'dart:math';

import 'package:ausadhi_khau/models/medicine.dart';
import 'package:ausadhi_khau/services/hive_service.dart';
import 'package:ausadhi_khau/services/notification_service.dart';
import 'package:flutter/foundation.dart';

class MedicineRepository {
  final HiveService _hiveService = HiveService();
  final NotificationService _notificationService = NotificationService();
  final Random _random = Random();

  Future<void> addMedicine(Medicine medicine) async {
    final existingMedicines = _hiveService.getAllMedicines();
    final isDuplicate = existingMedicines.any(
      (m) =>
          m.name.trim().toLowerCase() == medicine.name.trim().toLowerCase() &&
          m.dosage.trim().toLowerCase() == medicine.dosage.trim().toLowerCase(),
    );

    if (isDuplicate) {
      throw Exception(
        'Medicine "${medicine.name}" with this dosage already exists',
      );
    }

    await _hiveService.addMedicine(medicine);

    // Use global refresh to respect iOS 64 notification limit
    await refreshAllNotifications();
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final existingMedicines = _hiveService.getAllMedicines();
    final isDuplicate = existingMedicines.any(
      (m) =>
          m.id != medicine.id &&
          m.name.trim().toLowerCase() == medicine.name.trim().toLowerCase() &&
          m.dosage.trim().toLowerCase() == medicine.dosage.trim().toLowerCase(),
    );

    if (isDuplicate) {
      throw Exception(
        'Another medicine with this name and dosage already exists',
      );
    }

    await _hiveService.updateMedicine(medicine);

    // Use global refresh to respect iOS 64 notification limit
    await refreshAllNotifications();
  }

  Future<void> deleteMedicine(String id) async {
    await _hiveService.deleteMedicine(id);
    // Use global refresh to respect iOS 64 notification limit
    await refreshAllNotifications();
  }

  List<Medicine> getAllMedicines() {
    return _hiveService.getAllMedicines();
  }

  Future<void> clearAllData() async {
    await _hiveService.clearAll();
    await refreshAllNotifications();
  }

  Future<void> toggleMedicineStatus(String id, bool isActive) async {
    final medicine = _hiveService.getMedicine(id);
    if (medicine != null) {
      final updatedMedicine = medicine.copyWith(isActive: isActive);
      await updateMedicine(updatedMedicine);
    }
  }

  Future<void> skipMedicineForDate(String id, DateTime date) async {
    final medicine = _hiveService.getMedicine(id);
    if (medicine != null) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final updatedSkippedDates = List<DateTime>.from(medicine.skippedDates);
      if (!updatedSkippedDates.any((d) => _isSameDay(d, normalizedDate))) {
        updatedSkippedDates.add(normalizedDate);
        final updatedMedicine = medicine.copyWith(
          skippedDates: updatedSkippedDates,
        );
        await updateMedicine(updatedMedicine);
      }
    }
  }

  Future<void> unskipMedicineForDate(String id, DateTime date) async {
    final medicine = _hiveService.getMedicine(id);
    if (medicine != null) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final updatedSkippedDates = List<DateTime>.from(medicine.skippedDates)
        ..removeWhere((d) => _isSameDay(d, normalizedDate));
      final updatedMedicine = medicine.copyWith(
        skippedDates: updatedSkippedDates,
      );
      await updateMedicine(updatedMedicine);
    }
  }

  Future<void> manualEnableForDate(String id, DateTime date) async {
    final medicine = _hiveService.getMedicine(id);
    if (medicine != null) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final updatedManualActiveDates = List<DateTime>.from(
        medicine.manualActiveDates,
      );
      if (!updatedManualActiveDates.any((d) => _isSameDay(d, normalizedDate))) {
        updatedManualActiveDates.add(normalizedDate);
        final updatedMedicine = medicine.copyWith(
          manualActiveDates: updatedManualActiveDates,
        );
        await updateMedicine(updatedMedicine);
      }
    }
  }

  Future<void> removeManualEnableForDate(String id, DateTime date) async {
    final medicine = _hiveService.getMedicine(id);
    if (medicine != null) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final updatedManualActiveDates = List<DateTime>.from(
        medicine.manualActiveDates,
      )..removeWhere((d) => _isSameDay(d, normalizedDate));
      final updatedMedicine = medicine.copyWith(
        manualActiveDates: updatedManualActiveDates,
      );
      await updateMedicine(updatedMedicine);
    }
  }

  Future<void> toggleMedicineTime(
    String id,
    String time,
    bool isEnabled,
  ) async {
    final medicine = _hiveService.getMedicine(id);
    if (medicine != null) {
      final updatedDeactivatedTimes = List<String>.from(
        medicine.deactivatedTimes,
      );
      if (isEnabled) {
        updatedDeactivatedTimes.remove(time);
      } else {
        if (!updatedDeactivatedTimes.contains(time)) {
          updatedDeactivatedTimes.add(time);
        }
      }
      final updatedMedicine = medicine.copyWith(
        deactivatedTimes: updatedDeactivatedTimes,
      );
      await updateMedicine(updatedMedicine);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// iOS limits pending notifications to 64. We use 60 as our limit to be safe.
  /// This method collects ALL upcoming notifications across ALL medicines,
  /// sorts them by time, and schedules only the soonest 60.
  static const int _maxPendingNotifications = 60;

  Future<void> refreshAllNotifications() async {
    try {
      debugPrint('MedicineRepository: Starting notification refresh...');

      // First, cancel all existing notifications
      await _notificationService.cancelAllNotifications();

      final medicines = _hiveService.getAllMedicines();
      debugPrint('MedicineRepository: Found ${medicines.length} medicines');

      // Collect all potential notifications across all medicines
      final List<Map<String, dynamic>> allNotifications = [];

      for (final medicine in medicines) {
        if (medicine.isActive || medicine.manualActiveDates.isNotEmpty) {
          _collectNotificationsForMedicine(medicine, allNotifications);
        }
      }

      debugPrint(
        'MedicineRepository: Collected ${allNotifications.length} potential notifications',
      );

      // Sort by scheduled time (soonest first)
      allNotifications.sort((a, b) {
        final DateTime timeA = a['scheduledTime'] as DateTime;
        final DateTime timeB = b['scheduledTime'] as DateTime;
        return timeA.compareTo(timeB);
      });

      // Take only the first 60 (respecting iOS limit)
      final toSchedule = allNotifications
          .take(_maxPendingNotifications)
          .toList();
      debugPrint(
        'MedicineRepository: Scheduling ${toSchedule.length} notifications',
      );

      // Schedule them with retry logic
      int successCount = 0;
      int failCount = 0;

      for (final p in toSchedule) {
        final success = await _notificationService.scheduleMedicineReminder(
          medicineName: p['medicineName'] as String,
          dosage: p['dosage'] as String,
          id: p['id'] as int,
          scheduledTime: p['scheduledTime'] as DateTime,
          takeWithFood: p['takeWithFood'] as bool,
          notes: p['notes'] as String?,
        );

        if (success) {
          successCount++;
        } else {
          failCount++;
        }
      }

      debugPrint(
        'MedicineRepository: Scheduled $successCount notifications, $failCount failed',
      );

      // Verify scheduling
      final pendingCount = await _notificationService
          .getPendingNotificationsCount();
      debugPrint(
        'MedicineRepository: Verified $pendingCount pending notifications',
      );
    } catch (e) {
      debugPrint('MedicineRepository: Error refreshing notifications: $e');
      // Don't rethrow - allow app to continue functioning
    }
  }

  /// Collects all notification parameters for a single medicine into the provided list.
  /// Does NOT schedule them - just computes what would be scheduled.
  void _collectNotificationsForMedicine(
    Medicine medicine,
    List<Map<String, dynamic>> results,
  ) {
    // We'll collect up to 200 potential notifications per medicine
    // (to allow fair distribution when limited to 60 total)
    const int maxPerMedicine = 200;
    int count = 0;

    if (medicine.schedules.isNotEmpty) {
      for (final schedule in medicine.schedules) {
        if (count >= maxPerMedicine) break;
        count = _collectScheduleNotifications(
          medicine,
          schedule.dosage,
          schedule.times,
          schedule.frequency,
          schedule.daysOfWeek,
          schedule.daysOfMonth,
          schedule.startDate,
          schedule.endDate,
          count,
          results,
          maxPerMedicine,
        );
      }
    } else {
      _collectScheduleNotifications(
        medicine,
        medicine.dosage,
        medicine.times,
        medicine.frequency,
        medicine.daysOfWeek,
        medicine.daysOfMonth,
        medicine.startDate,
        medicine.endDate,
        count,
        results,
        maxPerMedicine,
      );
    }
  }

  /// Collects notification parameters for a schedule, including medicine metadata.
  /// Used by the global notification pool approach.
  int _collectScheduleNotifications(
    Medicine medicine,
    String dosage,
    List<String> times,
    String frequency,
    List<int> daysOfWeek,
    List<int> daysOfMonth,
    DateTime startDateRaw,
    DateTime? endDateRaw,
    int startOffset,
    List<Map<String, dynamic>> results,
    int maxLimit,
  ) {
    final now = DateTime.now();

    // The effective start date for scheduling is the LATER of (now) and (user's startDate)
    final startOfWindow = startDateRaw.isAfter(now) ? startDateRaw : now;

    // The effective end date for scheduling is the SOONER of (now + 60 days) and (user's endDate)
    final sixtyDaysFromNow = now.add(const Duration(days: 60));
    final endOfWindow =
        (endDateRaw == null || endDateRaw.isAfter(sixtyDaysFromNow))
        ? sixtyDaysFromNow
        : endDateRaw;

    // If the window is invalid (start after end), nothing to schedule
    if (startOfWindow.isAfter(endOfWindow)) return startOffset;

    int currentOffset = startOffset;

    for (final time in times) {
      if (currentOffset >= maxLimit) break;

      if (medicine.deactivatedTimes.contains(time)) continue;

      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (frequency == 'daily') {
        // Daily: schedule for every day in the window
        DateTime nextDate = startOfWindow;
        while (nextDate.isBefore(endOfWindow) && currentOffset < maxLimit) {
          // Check if this specific date is effectively active
          bool isActiveForDate = medicine.isActive;
          if (isActiveForDate) {
            // If active, check for a skip
            if (medicine.skippedDates.any((d) => _isSameDay(d, nextDate))) {
              isActiveForDate = false;
            }
          } else {
            // If paused, check for a manual enable
            if (medicine.manualActiveDates.any(
              (d) => _isSameDay(d, nextDate),
            )) {
              isActiveForDate = true;
            }
          }

          if (isActiveForDate) {
            final scheduledTime = DateTime(
              nextDate.year,
              nextDate.month,
              nextDate.day,
              hour,
              minute,
            );

            // Double check that we are still in bounds of the user's specific range
            // and actually in the future
            if (scheduledTime.isAfter(now) &&
                !scheduledTime.isBefore(startDateRaw) &&
                (endDateRaw == null || !scheduledTime.isAfter(endDateRaw))) {
              results.add({
                'medicineName': medicine.name,
                'dosage': dosage,
                'id': _notificationService.generateUniqueId(
                  medicine.id,
                  currentOffset,
                ),
                'scheduledTime': scheduledTime,
                'takeWithFood': medicine.takeWithFood,
                'notes': medicine.notes,
              });
              currentOffset++;
            }
          }
          nextDate = nextDate.add(const Duration(days: 1));
        }
      } else if (frequency == 'weekly') {
        for (final day in daysOfWeek) {
          DateTime nextDate = startOfWindow;
          // Align to the specific day of week
          while (nextDate.weekday != day) {
            nextDate = nextDate.add(const Duration(days: 1));
          }

          while (nextDate.isBefore(endOfWindow) && currentOffset < maxLimit) {
            // Check if this specific date is effectively active
            bool isActiveForDate = medicine.isActive;
            if (isActiveForDate) {
              // If active, check for a skip
              if (medicine.skippedDates.any((d) => _isSameDay(d, nextDate))) {
                isActiveForDate = false;
              }
            } else {
              // If paused, check for a manual enable
              if (medicine.manualActiveDates.any(
                (d) => _isSameDay(d, nextDate),
              )) {
                isActiveForDate = true;
              }
            }

            if (isActiveForDate) {
              final scheduledTime = DateTime(
                nextDate.year,
                nextDate.month,
                nextDate.day,
                hour,
                minute,
              );

              // Double check that we are still in bounds of the user's specific range
              // and actually in the future
              if (scheduledTime.isAfter(now) &&
                  !scheduledTime.isBefore(startDateRaw) &&
                  (endDateRaw == null || !scheduledTime.isAfter(endDateRaw))) {
                results.add({
                  'medicineName': medicine.name,
                  'dosage': dosage,
                  'id': _notificationService.generateUniqueId(
                    medicine.id,
                    currentOffset,
                  ),
                  'scheduledTime': scheduledTime,
                  'takeWithFood': medicine.takeWithFood,
                  'notes': medicine.notes,
                });
                currentOffset++;
              }
            }
            nextDate = nextDate.add(const Duration(days: 7));
          }
        }
      } else if (frequency == 'monthly') {
        final List<int> daysToSchedule = daysOfMonth.isEmpty
            ? [startDateRaw.day]
            : daysOfMonth;

        for (final dom in daysToSchedule) {
          if (currentOffset >= maxLimit) break;

          DateTime nextDate = DateTime(
            startOfWindow.year,
            startOfWindow.month,
            dom,
          );
          if (nextDate.isBefore(startOfWindow)) {
            nextDate = DateTime(
              startOfWindow.year,
              startOfWindow.month + 1,
              dom,
            );
          }

          while (nextDate.isBefore(endOfWindow) && currentOffset < maxLimit) {
            bool isActiveForDate = medicine.isActive;
            if (isActiveForDate) {
              if (medicine.skippedDates.any((d) => _isSameDay(d, nextDate))) {
                isActiveForDate = false;
              }
            } else {
              if (medicine.manualActiveDates.any(
                (d) => _isSameDay(d, nextDate),
              )) {
                isActiveForDate = true;
              }
            }

            if (isActiveForDate) {
              final scheduledTime = DateTime(
                nextDate.year,
                nextDate.month,
                nextDate.day,
                hour,
                minute,
              );

              if (scheduledTime.isAfter(now) &&
                  !scheduledTime.isBefore(startDateRaw) &&
                  (endDateRaw == null || !scheduledTime.isAfter(endDateRaw))) {
                results.add({
                  'medicineName': medicine.name,
                  'dosage': dosage,
                  'id': _notificationService.generateUniqueId(
                    medicine.id,
                    currentOffset,
                  ),
                  'scheduledTime': scheduledTime,
                  'takeWithFood': medicine.takeWithFood,
                  'notes': medicine.notes,
                });
                currentOffset++;
              }
            }

            int m = nextDate.month + 1;
            int y = nextDate.year;
            if (m > 12) {
              m = 1;
              y++;
            }
            final lastDay = DateTime(y, m + 1, 0).day;
            nextDate = DateTime(y, m, dom > lastDay ? lastDay : dom);
          }
        }
      } else if (frequency == 'yearly') {
        DateTime nextDate = startDateRaw;
        while (nextDate.isBefore(startOfWindow)) {
          nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
        }
        while (nextDate.isBefore(endOfWindow) && currentOffset < maxLimit) {
          final scheduledTime = DateTime(
            nextDate.year,
            nextDate.month,
            nextDate.day,
            hour,
            minute,
          );
          if (scheduledTime.isAfter(now) &&
              !scheduledTime.isBefore(startDateRaw) &&
              (endDateRaw == null || !scheduledTime.isAfter(endDateRaw))) {
            results.add({
              'medicineName': medicine.name,
              'dosage': dosage,
              'id': _notificationService.generateUniqueId(
                medicine.id,
                currentOffset,
              ),
              'scheduledTime': scheduledTime,
              'takeWithFood': medicine.takeWithFood,
              'notes': medicine.notes,
            });
            currentOffset++;
          }
          nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
        }
      }
    }
    return currentOffset;
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(9999).toString();
  }
}
