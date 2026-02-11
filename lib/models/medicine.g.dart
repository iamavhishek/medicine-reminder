// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final typeId = 0;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      id: fields[0] as String,
      name: fields[1] as String,
      dosage: fields[2] as String,
      daysOfWeek: (fields[3] as List).cast<int>(),
      times: (fields[4] as List).cast<String>(),
      startDate: fields[5] as DateTime,
      endDate: fields[6] as DateTime?,
      isActive: fields[7] == null ? false : fields[7] as bool,
      takeWithFood: fields[8] == null ? false : fields[8] as bool,
      notes: fields[9] as String?,
      frequency: fields[10] == null ? 'weekly' : fields[10] as String,
      daysOfMonth: fields[11] == null ? [] : (fields[11] as List).cast<int>(),
      schedules: fields[12] == null
          ? []
          : (fields[12] as List).cast<MedicineSchedule>(),
      type: fields[13] == null ? 'pill' : fields[13] as String,
      dosageUnit: fields[14] == null ? 'tablet' : fields[14] as String,
      skippedDates: fields[15] == null
          ? []
          : (fields[15] as List).cast<DateTime>(),
      manualActiveDates: fields[16] == null
          ? []
          : (fields[16] as List).cast<DateTime>(),
      deactivatedTimes: fields[17] == null
          ? []
          : (fields[17] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dosage)
      ..writeByte(3)
      ..write(obj.daysOfWeek)
      ..writeByte(4)
      ..write(obj.times)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.takeWithFood)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.frequency)
      ..writeByte(11)
      ..write(obj.daysOfMonth)
      ..writeByte(12)
      ..write(obj.schedules)
      ..writeByte(13)
      ..write(obj.type)
      ..writeByte(14)
      ..write(obj.dosageUnit)
      ..writeByte(15)
      ..write(obj.skippedDates)
      ..writeByte(16)
      ..write(obj.manualActiveDates)
      ..writeByte(17)
      ..write(obj.deactivatedTimes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Medicine _$MedicineFromJson(Map<String, dynamic> json) => _Medicine(
  id: json['id'] as String,
  name: json['name'] as String,
  dosage: json['dosage'] as String,
  daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  times: (json['times'] as List<dynamic>).map((e) => e as String).toList(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  isActive: json['isActive'] as bool? ?? false,
  takeWithFood: json['takeWithFood'] as bool? ?? false,
  notes: json['notes'] as String?,
  frequency: json['frequency'] as String? ?? 'weekly',
  daysOfMonth:
      (json['daysOfMonth'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  schedules:
      (json['schedules'] as List<dynamic>?)
          ?.map((e) => MedicineSchedule.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  type: json['type'] as String? ?? 'pill',
  dosageUnit: json['dosageUnit'] as String? ?? 'tablet',
  skippedDates:
      (json['skippedDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList() ??
      const [],
  manualActiveDates:
      (json['manualActiveDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList() ??
      const [],
  deactivatedTimes:
      (json['deactivatedTimes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$MedicineToJson(_Medicine instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'dosage': instance.dosage,
  'daysOfWeek': instance.daysOfWeek,
  'times': instance.times,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'isActive': instance.isActive,
  'takeWithFood': instance.takeWithFood,
  'notes': instance.notes,
  'frequency': instance.frequency,
  'daysOfMonth': instance.daysOfMonth,
  'schedules': instance.schedules.map((e) => e.toJson()).toList(),
  'type': instance.type,
  'dosageUnit': instance.dosageUnit,
  'skippedDates': instance.skippedDates
      .map((e) => e.toIso8601String())
      .toList(),
  'manualActiveDates': instance.manualActiveDates
      .map((e) => e.toIso8601String())
      .toList(),
  'deactivatedTimes': instance.deactivatedTimes,
};
