import 'package:equatable/equatable.dart';
import 'package:medicine_remainder_app/models/medicine.dart';

abstract class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object> get props => [];
}

class LoadMedicines extends MedicineEvent {}

class RescheduleNotificationsEvent extends MedicineEvent {}

class UpdateSelectedDate extends MedicineEvent {
  final DateTime selectedDate;

  const UpdateSelectedDate(this.selectedDate);

  @override
  List<Object> get props => [selectedDate];
}

class AddMedicineEvent extends MedicineEvent {
  final Medicine medicine;

  const AddMedicineEvent(this.medicine);

  @override
  List<Object> get props => [medicine];
}

class UpdateMedicineEvent extends MedicineEvent {
  final Medicine medicine;

  const UpdateMedicineEvent(this.medicine);

  @override
  List<Object> get props => [medicine];
}

class DeleteMedicineEvent extends MedicineEvent {
  final String id;

  const DeleteMedicineEvent(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleMedicineStatusEvent extends MedicineEvent {
  final String id;
  final bool isActive;

  const ToggleMedicineStatusEvent(this.id, this.isActive);

  @override
  List<Object> get props => [id, isActive];
}

class SkipMedicineForDateEvent extends MedicineEvent {
  final String id;
  final DateTime date;

  const SkipMedicineForDateEvent(this.id, this.date);

  @override
  List<Object> get props => [id, date];
}

class UnskipMedicineForDateEvent extends MedicineEvent {
  final String id;
  final DateTime date;

  const UnskipMedicineForDateEvent(this.id, this.date);

  @override
  List<Object> get props => [id, date];
}

class ManualEnableForDateEvent extends MedicineEvent {
  final String id;
  final DateTime date;

  const ManualEnableForDateEvent(this.id, this.date);

  @override
  List<Object> get props => [id, date];
}

class RemoveManualEnableForDateEvent extends MedicineEvent {
  final String id;
  final DateTime date;

  const RemoveManualEnableForDateEvent(this.id, this.date);

  @override
  List<Object> get props => [id, date];
}

class ToggleMedicineTimeEvent extends MedicineEvent {
  final String medicineId;
  final String time;
  final bool isEnabled;

  const ToggleMedicineTimeEvent({
    required this.medicineId,
    required this.time,
    required this.isEnabled,
  });

  @override
  List<Object> get props => [medicineId, time, isEnabled];
}

class ClearAllMedicinesEvent extends MedicineEvent {}
