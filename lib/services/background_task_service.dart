import 'package:ausadhi_khau/repositories/medicine_repository.dart';
import 'package:ausadhi_khau/services/hive_service.dart';
import 'package:ausadhi_khau/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// Background task identifiers
const String refreshNotificationsTask = 'refreshNotificationsTask';
const String periodicRefreshTask = 'periodicRefreshTask';

/// Top-level callback for workmanager - must be outside any class
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('BackgroundTaskService: Executing $taskName');

    try {
      // Initialize services (they may not be initialized in background)
      await HiveService().init();
      await NotificationService().initialize();

      switch (taskName) {
        case refreshNotificationsTask:
        case periodicRefreshTask:
          await MedicineRepository().refreshAllNotifications();
          debugPrint(
            'BackgroundTaskService: Notifications refreshed successfully',
          );
          break;
        default:
          debugPrint('BackgroundTaskService: Unknown task $taskName');
      }

      return true;
    } catch (e) {
      debugPrint('BackgroundTaskService: Task $taskName failed: $e');
      return false;
    }
  });
}

/// Service for managing background tasks to ensure notification reliability
class BackgroundTaskService {
  static final BackgroundTaskService _instance =
      BackgroundTaskService._internal();
  factory BackgroundTaskService() => _instance;
  BackgroundTaskService._internal();

  bool _isInitialized = false;

  /// Initialize the background task service
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    // Workmanager only supports Android and iOS
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      debugPrint(
        'BackgroundTaskService: Skipping initialization on unsupported platform',
      );
      _isInitialized = true;
      return;
    }

    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );
      _isInitialized = true;
      debugPrint('BackgroundTaskService initialized');
    } catch (e) {
      debugPrint('BackgroundTaskService initialization failed: $e');
    }
  }

  /// Schedule periodic notification refresh (every 6 hours)
  /// This ensures notifications stay up-to-date even if app isn't opened
  Future<void> schedulePeriodicRefresh() async {
    if (kIsWeb || !_isInitialized) return;

    // Workmanager only supports Android and iOS
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      // Cancel any existing periodic tasks
      await Workmanager().cancelByUniqueName(periodicRefreshTask);

      // Schedule new periodic task
      await Workmanager().registerPeriodicTask(
        periodicRefreshTask,
        periodicRefreshTask,
        frequency: const Duration(hours: 6),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );

      debugPrint('Periodic notification refresh scheduled (every 6 hours)');
    } catch (e) {
      debugPrint('Failed to schedule periodic refresh: $e');
    }
  }

  /// Schedule an immediate one-time notification refresh
  Future<void> scheduleImmediateRefresh() async {
    if (kIsWeb || !_isInitialized) return;

    // Workmanager only supports Android and iOS
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      await Workmanager().registerOneOffTask(
        '${refreshNotificationsTask}_${DateTime.now().millisecondsSinceEpoch}',
        refreshNotificationsTask,
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
        ),
      );

      debugPrint('Immediate notification refresh scheduled');
    } catch (e) {
      debugPrint('Failed to schedule immediate refresh: $e');
    }
  }

  /// Cancel all background tasks
  Future<void> cancelAll() async {
    if (kIsWeb) return;

    // Workmanager only supports Android and iOS
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      await Workmanager().cancelAll();
      debugPrint('All background tasks cancelled');
    } catch (e) {
      debugPrint('Failed to cancel background tasks: $e');
    }
  }
}
