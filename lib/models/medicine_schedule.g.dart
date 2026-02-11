// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineScheduleAdapter extends TypeAdapter<MedicineSchedule> {
  @override
  final typeId = 1;

  @override
  MedicineSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineSchedule(
      dosage: fields[0] as String,
      times: (fields[1] as List).cast<String>(),
      frequency: fields[2] == null ? 'weekly' : fields[2] as String,
      daysOfWeek: fields[3] == null ? [] : (fields[3] as List).cast<int>(),
      daysOfMonth: fields[4] == null ? [] : (fields[4] as List).cast<int>(),
      startDate: fields[5] as DateTime,
      endDate: fields[6] as DateTime?,
      deactivatedTimes: fields[7] == null
          ? []
          : (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MedicineSchedule obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.dosage)
      ..writeByte(1)
      ..write(obj.times)
      ..writeByte(2)
      ..write(obj.frequency)
      ..writeByte(3)
      ..write(obj.daysOfWeek)
      ..writeByte(4)
      ..write(obj.daysOfMonth)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.deactivatedTimes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicineSchedule _$MedicineScheduleFromJson(Map<String, dynamic> json) =>
    _MedicineSchedule(
      dosage: json['dosage'] as String,
      times: (json['times'] as List<dynamic>).map((e) => e as String).toList(),
      frequency: json['frequency'] as String? ?? 'weekly',
      daysOfWeek:
          (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      daysOfMonth:
          (json['daysOfMonth'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      deactivatedTimes:
          (json['deactivatedTimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MedicineScheduleToJson(_MedicineSchedule instance) =>
    <String, dynamic>{
      'dosage': instance.dosage,
      'times': instance.times,
      'frequency': instance.frequency,
      'daysOfWeek': instance.daysOfWeek,
      'daysOfMonth': instance.daysOfMonth,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'deactivatedTimes': instance.deactivatedTimes,
    };
