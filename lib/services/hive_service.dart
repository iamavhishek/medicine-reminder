import 'dart:convert';
import 'dart:io';

import 'package:ausadhi_khau/models/medicine.dart';
import 'package:ausadhi_khau/models/medicine_schedule.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String medicinesBox = 'medicines_box';
  static const String settingsBox = 'settings_box';

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(MedicineAdapter());
    Hive.registerAdapter(MedicineScheduleAdapter());

    // Open boxes
    await Hive.openBox<Medicine>(medicinesBox);
    await Hive.openBox(settingsBox);
  }

  Box<Medicine> getMedicinesBox() {
    return Hive.box<Medicine>(medicinesBox);
  }

  Future<void> addMedicine(Medicine medicine) async {
    final box = getMedicinesBox();
    await box.put(medicine.id, medicine);
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final box = getMedicinesBox();
    await box.put(medicine.id, medicine);
  }

  Future<void> deleteMedicine(String id) async {
    final box = getMedicinesBox();
    await box.delete(id);
  }

  List<Medicine> getAllMedicines() {
    final box = getMedicinesBox();
    return box.values.toList();
  }

  Medicine? getMedicine(String id) {
    final box = getMedicinesBox();
    return box.get(id);
  }

  Future<void> clearAll() async {
    final box = getMedicinesBox();
    await box.clear();
  }

  // Settings helpers
  bool isOnboardingCompleted() {
    final box = Hive.box(settingsBox);
    return box.get('onboarding_completed', defaultValue: false) as bool;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final box = Hive.box(settingsBox);
    await box.put('onboarding_completed', value);
  }

  bool isNotificationsEnabled() {
    final box = Hive.box(settingsBox);
    return box.get('notifications_enabled', defaultValue: true) as bool;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final box = Hive.box(settingsBox);
    await box.put('notifications_enabled', value);
  }

  bool isSoundsEnabled() {
    final box = Hive.box(settingsBox);
    return box.get('sounds_enabled', defaultValue: true) as bool;
  }

  Future<void> setSoundsEnabled(bool value) async {
    final box = Hive.box(settingsBox);
    await box.put('sounds_enabled', value);
  }

  String getThemeMode() {
    final box = Hive.box(settingsBox);
    return box.get('theme_mode', defaultValue: 'system') as String;
  }

  Future<void> setThemeMode(String themeMode) async {
    final box = Hive.box(settingsBox);
    await box.put('theme_mode', themeMode);
  }

  // Data Export/Import for QR Code Sharing
  // Uses GZip compression + Base64 to minimize QR code size

  /// Export all medicines as a compressed base64 string
  String exportMedicines() {
    final medicines = getAllMedicines();
    final jsonList = medicines.map((m) => m.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    // Compress using GZip
    final bytes = utf8.encode(jsonString);
    final compressed = gzip.encode(bytes);
    final base64String = base64Encode(compressed);

    return base64String;
  }

  /// Import medicines from a compressed base64 string
  /// Returns the number of medicines imported
  Future<int> importMedicines(String data) async {
    try {
      // Decompress
      final compressed = base64Decode(data);
      final bytes = gzip.decode(compressed);
      final jsonString = utf8.decode(bytes);

      final jsonList = jsonDecode(jsonString) as List;
      final medicines = jsonList
          .map((json) => Medicine.fromJson(json as Map<String, dynamic>))
          .toList();

      // Save all (upsert based on ID)
      for (final medicine in medicines) {
        await addMedicine(medicine);
      }

      return medicines.length;
    } catch (e) {
      debugPrint('Import failed: $e');
      throw const FormatException('Invalid QR code data');
    }
  }
}
