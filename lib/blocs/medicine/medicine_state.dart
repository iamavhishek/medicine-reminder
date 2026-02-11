import 'package:ausadhi_khau/models/medicine.dart';
import 'package:equatable/equatable.dart';

abstract class MedicineState extends Equatable {
  final List<Medicine> medicines;
  final DateTime selectedDate;

  const MedicineState({this.medicines = const [], required this.selectedDate});

  @override
  List<Object> get props => [medicines, selectedDate];
}

class MedicineInitial extends MedicineState {
  const MedicineInitial({required super.selectedDate});

  @override
  List<Object> get props => [selectedDate];
}

class MedicineLoading extends MedicineState {
  const MedicineLoading({super.medicines, required super.selectedDate});

  @override
  List<Object> get props => [medicines, selectedDate];
}

class MedicineLoaded extends MedicineState {
  const MedicineLoaded({required super.medicines, required super.selectedDate});

  @override
  List<Object> get props => [medicines, selectedDate];
}

class MedicineOperationSuccess extends MedicineState {
  final String message;
  const MedicineOperationSuccess({
    required this.message,
    required super.medicines,
    required super.selectedDate,
  });

  @override
  List<Object> get props => [message, medicines, selectedDate];
}

class MedicineError extends MedicineState {
  final String error;
  const MedicineError({
    required this.error,
    required super.medicines,
    required super.selectedDate,
  });

  @override
  List<Object> get props => [error, medicines, selectedDate];
}
