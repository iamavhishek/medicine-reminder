import 'package:ausadhi_khau/blocs/medicine/medicine_event.dart';
import 'package:ausadhi_khau/blocs/medicine/medicine_state.dart';
import 'package:ausadhi_khau/repositories/medicine_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final MedicineRepository _repository;

  MedicineBloc({required MedicineRepository repository})
    : _repository = repository,
      super(MedicineInitial(selectedDate: DateTime.now())) {
    on<LoadMedicines>(_onLoadMedicines);
    on<UpdateSelectedDate>(_onUpdateSelectedDate);
    on<AddMedicineEvent>(_onAddMedicine);
    on<UpdateMedicineEvent>(_onUpdateMedicine);
    on<DeleteMedicineEvent>(_onDeleteMedicine);
    on<ToggleMedicineStatusEvent>(_onToggleMedicineStatus);
    on<SkipMedicineForDateEvent>(_onSkipMedicineForDate);
    on<UnskipMedicineForDateEvent>(_onUnskipMedicineForDate);
    on<ManualEnableForDateEvent>(_onManualEnableForDate);
    on<RemoveManualEnableForDateEvent>(_onRemoveManualEnableForDate);
    on<ToggleMedicineTimeEvent>(_onToggleMedicineTime);
    on<RescheduleNotificationsEvent>(_onRescheduleNotifications);
    on<ClearAllMedicinesEvent>(_onClearAllMedicines);
  }

  Future<void> _onRescheduleNotifications(
    RescheduleNotificationsEvent event,
    Emitter<MedicineState> emit,
  ) async {
    // Just trigger repository refresh
    await _repository.refreshAllNotifications();
  }

  Future<void> _onLoadMedicines(
    LoadMedicines event,
    Emitter<MedicineState> emit,
  ) async {
    emit(
      MedicineLoading(
        medicines: state.medicines,
        selectedDate: state.selectedDate,
      ),
    );
    try {
      final medicines = _repository.getAllMedicines();
      emit(
        MedicineLoaded(medicines: medicines, selectedDate: state.selectedDate),
      );
      // Refresh notifications in the background to push the 60-day window forward
      await _repository.refreshAllNotifications();
    } catch (e) {
      emit(
        MedicineError(
          error: e.toString(),
          medicines: state.medicines,
          selectedDate: state.selectedDate,
        ),
      );
    }
  }

  void _onUpdateSelectedDate(
    UpdateSelectedDate event,
    Emitter<MedicineState> emit,
  ) {
    emit(
      MedicineLoaded(
        medicines: state.medicines,
        selectedDate: event.selectedDate,
      ),
    );
  }

  Future<void> _onAddMedicine(
    AddMedicineEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(
      MedicineLoading(
        medicines: state.medicines,
        selectedDate: state.selectedDate,
      ),
    );
    try {
      await _repository.addMedicine(event.medicine);
      final medicines = _repository.getAllMedicines();
      emit(
        MedicineOperationSuccess(
          message: 'Medicine added successfully',
          medicines: medicines,
          selectedDate: state.selectedDate,
        ),
      );
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      emit(
        MedicineError(
          error: errorMessage,
          medicines: state.medicines,
          selectedDate: state.selectedDate,
        ),
      );
    }
  }

  Future<void> _onUpdateMedicine(
    UpdateMedicineEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(
      MedicineLoading(
        medicines: state.medicines,
        selectedDate: state.selectedDate,
      ),
    );
    try {
      await _repository.updateMedicine(event.medicine);
      final medicines = _repository.getAllMedicines();
      emit(
        MedicineOperationSuccess(
          message: 'Medicine updated successfully',
          medicines: medicines,
          selectedDate: state.selectedDate,
        ),
      );
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      emit(
        MedicineError(
          error: errorMessage,
          medicines: state.medicines,
          selectedDate: state.selectedDate,
        ),
      );
    }
  }

  Future<void> _onDeleteMedicine(
    DeleteMedicineEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(
      MedicineLoading(
        medicines: state.medicines,
        selectedDate: state.selectedDate,
      ),
    );
    try {
      await _repository.deleteMedicine(event.id);
      final medicines = _repository.getAllMedicines();
      emit(
        MedicineOperationSuccess(
          message: 'Medicine deleted successfully',
          medicines: medicines,
          selectedDate: state.selectedDate,
        ),
      );
    } catch (e) {
      emit(
        MedicineError(
          error: e.toString(),
          medicines: state.medicines,
          selectedDate: state.selectedDate,
        ),
      );
    }
  }

  Future<void> _onToggleMedicineStatus(
    ToggleMedicineStatusEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(
      MedicineLoading(
        medicines: state.medicines,
        selectedDate: state.selectedDate,
      ),
    );
    try {
      await _repository.toggleMedicineStatus(event.id, event.isActive);
      final medicines = _repository.getAllMedicines();
      emit(
        MedicineLoaded(medicines: medicines, selectedDate: state.selectedDate),
      );
    } catch (e) {
      emit(
        MedicineError(
          error: e.toString(),
          medicines: state.medicines,
          selectedDate: state.selectedDate,
        ),
      );
    }
  }

  Future<void> _onSkipMedicineForDate(
    SkipMedicineForDateEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(
      MedicineLoading(
        medicines: state.medicines,
        selectedDate: state.selectedDate,
      ),
    );
    try {
      await _repository.skipMedicineForDate(event.id, event.date);
      final medicines = _repository.getAllMedicines();
      emit(
        MedicineLoaded(medicines: medicines, selectedDate: state.selectedDate),
      );
    } catch (e) {
      emit(
        MedicineError(
          error: e.toString(),
          medicines: state.medicines,
          selectedDate: state.selectedDate,
        ),
      );
    }
  }

  Future<void> _onUnskipMedicineForDate(
    UnskipMedicineForDateEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(
      MedicineLoading(
        medicines: state.medicines,
        selectedDate: state.selectedDate,
      ),
    );
    try {
      await _repository.unskipMedicineForDate(event.id, event.date);
      final medicines = _repository.getAllMedicines();
      emit(
        MedicineLoaded(medicines: medicines, selectedDate: state.selectedDate),
      );
    } catch (e) {
      emit(
        MedicineError(
          error: e.toString(),
          medicines: state.medicines,
          selectedDate: state.selectedDate,
        ),
      );
    }
  }

  Future<void> _onManualEnableForDate(
    ManualEnableForDateEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(
      MedicineLoading(
        medicines: state.medicines,
        selectedDate: state.selectedDate,
      ),
    );
    try {
      await _repository.manualEnableForDate(event.id, event.date);
      final medicines = _repository.getAllMedicines();
      emit(
        MedicineLoaded(medicines: medicines, selectedDate: state.selectedDate),
      );
    } catch (e) {
      emit(
        MedicineError(
          error: e.toString(),
          medicines: state.medicines,
          selectedDate: state.selectedDate,
        ),
      );
    }
  }

  Future<void> _onRemoveManualEnableForDate(
    RemoveManualEnableForDateEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(
      MedicineLoading(
        medicines: state.medicines,
        selectedDate: state.selectedDate,
      ),
    );
    try {
      await _repository.removeManualEnableForDate(event.id, event.date);
      final medicines = _repository.getAllMedicines();
      emit(
        MedicineLoaded(medicines: medicines, selectedDate: state.selectedDate),
      );
    } catch (e) {
      emit(
        MedicineError(
          error: e.toString(),
          medicines: state.medicines,
          selectedDate: state.selectedDate,
        ),
      );
    }
  }

  Future<void> _onToggleMedicineTime(
    ToggleMedicineTimeEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(
      MedicineLoading(
        medicines: state.medicines,
        selectedDate: state.selectedDate,
      ),
    );
    try {
      await _repository.toggleMedicineTime(
        event.medicineId,
        event.time,
        event.isEnabled,
      );
      final medicines = _repository.getAllMedicines();
      emit(
        MedicineLoaded(medicines: medicines, selectedDate: state.selectedDate),
      );
    } catch (e) {
      emit(
        MedicineError(
          error: e.toString(),
          medicines: state.medicines,
          selectedDate: state.selectedDate,
        ),
      );
    }
  }

  Future<void> _onClearAllMedicines(
    ClearAllMedicinesEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(
      MedicineLoading(
        medicines: state.medicines,
        selectedDate: state.selectedDate,
      ),
    );
    try {
      await _repository.clearAllData();
      emit(
        MedicineOperationSuccess(
          message: 'All data cleared successfully',
          medicines: const [],
          selectedDate: state.selectedDate,
        ),
      );
    } catch (e) {
      emit(
        MedicineError(
          error: e.toString(),
          medicines: state.medicines,
          selectedDate: state.selectedDate,
        ),
      );
    }
  }
}
