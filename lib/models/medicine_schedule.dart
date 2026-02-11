import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

part 'medicine_schedule.freezed.dart';
part 'medicine_schedule.g.dart';

@freezed
@HiveType(typeId: 1)
abstract class MedicineSchedule with _$MedicineSchedule {
  const factory MedicineSchedule({
    @HiveField(0) required String dosage,
    @HiveField(1) required List<String> times,
    @HiveField(2) @Default('weekly') String frequency,
    @HiveField(3) @Default([]) List<int> daysOfWeek,
    @HiveField(4) @Default([]) List<int> daysOfMonth,
    @HiveField(5) required DateTime startDate,
    @HiveField(6) DateTime? endDate,
    @HiveField(7) @Default([]) List<String> deactivatedTimes,
  }) = _MedicineSchedule;

  factory MedicineSchedule.fromJson(Map<String, dynamic> json) =>
      _$MedicineScheduleFromJson(json);
}
