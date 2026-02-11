import 'package:ausadhi_khau/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final ThemeMode themeMode;
  ThemeChanged(this.themeMode);
}

class LoadTheme extends ThemeEvent {}

// State
class ThemeState {
  final ThemeMode themeMode;
  ThemeState(this.themeMode);
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final HiveService _hiveService;

  ThemeBloc(this._hiveService) : super(ThemeState(ThemeMode.system)) {
    on<LoadTheme>((event, emit) {
      final themeStr = _hiveService.getThemeMode();
      final mode = ThemeMode.values.firstWhere(
        (e) => e.name == themeStr,
        orElse: () => ThemeMode.system,
      );
      emit(ThemeState(mode));
    });

    on<ThemeChanged>((event, emit) async {
      await _hiveService.setThemeMode(event.themeMode.name);
      emit(ThemeState(event.themeMode));
    });
  }
}
