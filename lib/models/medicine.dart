import 'package:ausadhi_khau/models/medicine_schedule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

part 'medicine.freezed.dart';
part 'medicine.g.dart';

@freezed
@HiveType(typeId: 0)
abstract class Medicine with _$Medicine {
  const factory Medicine({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String dosage,
    @HiveField(3) required List<int> daysOfWeek,
    @HiveField(4) required List<String> times,
    @HiveField(5) required DateTime startDate,
    @HiveField(6) DateTime? endDate,
    @HiveField(7) @Default(false) bool isActive,
    @HiveField(8) @Default(false) bool takeWithFood,
    @HiveField(9) String? notes,
    @HiveField(10) @Default('weekly') String frequency,
    @HiveField(11) @Default([]) List<int> daysOfMonth,
    @HiveField(12) @Default([]) List<MedicineSchedule> schedules,
    @HiveField(13) @Default('pill') String type,
    @HiveField(14) @Default('tablet') String dosageUnit,
    @HiveField(15) @Default([]) List<DateTime> skippedDates,
    @HiveField(16) @Default([]) List<DateTime> manualActiveDates,
    @HiveField(17) @Default([]) List<String> deactivatedTimes,
  }) = _Medicine;

  factory Medicine.fromJson(Map<String, dynamic> json) =>
      _$MedicineFromJson(json);
}
