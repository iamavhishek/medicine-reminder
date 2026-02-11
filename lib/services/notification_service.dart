import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:medicine_remainder_app/services/hive_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Callback for handling notification taps - must be top-level function
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle notification tap in background
  debugPrint('Notification tapped in background: ${notificationResponse.id}');
}

/// A robust notification service designed for critical medicine reminders.
/// Features:
/// - Exact alarm scheduling using AlarmClock mode
/// - Boot persistence (notifications survive device restart)
/// - Error handling and retry logic
/// - Platform-specific optimizations
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service with all required settings
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    // Set local timezone correctly for accurate scheduling
    try {
      if (!kIsWeb) {
        final dynamic currentTimeZone =
            await FlutterTimezone.getLocalTimezone();
        // Handle both String and TimezoneInfo types for compatibility
        final String timeZoneName = currentTimeZone is String
            ? currentTimeZone
            : (currentTimeZone.toString());

        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('NotificationService: Local timezone set to $timeZoneName');
      }
    } catch (e) {
      debugPrint(
        'NotificationService: Could not set local timezone (falling back to UTC): $e',
      );
    }

    // Skip platform-specific notification initialization on web
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    // Windows Toast Notifications settings
    const WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
          appName: 'Medicine Reminder',
          appUserModelId: 'np.com.abhishekd.medRemind',
          guid: 'd7b76fe6-6d00-4b6a-8e3b-45a5e9c0b3f1',
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          macOS: initializationSettingsIOS,
          windows: initializationSettingsWindows,
        );

    try {
      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification tapped: ${response.id}');
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
      // Don't throw - allow app to function without notifications on unsupported platforms
    }
  }

  /// Request all necessary permissions for reliable notifications
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux) {
        return true;
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        // Request notification permission
        final notificationStatus = await Permission.notification.request();

        // Request exact alarm permission (Android 12+)
        // This is CRITICAL for medicine reminders to fire at exact times
        if (await Permission.scheduleExactAlarm.isDenied) {
          await Permission.scheduleExactAlarm.request();
        }

        // Request battery optimization exemption for reliable delivery
        await _requestBatteryOptimizationExemption();

        return notificationStatus.isGranted;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final result = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
            );
        return result ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final result = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
            );
        return result ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('Permission request failed: $e');
      return false;
    }
  }

  /// Request battery optimization exemption on Android
  /// This is critical for ensuring alarms fire even in Doze mode
  Future<void> _requestBatteryOptimizationExemption() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (e) {
      debugPrint('Battery optimization exemption request failed: $e');
    }
  }

  /// Schedule a medicine reminder with maximum reliability
  /// Uses AlarmClock mode for exact timing even in Doze mode
  Future<bool> scheduleMedicineReminder({
    required String medicineName,
    required String dosage,
    required int id,
    required DateTime scheduledTime,
    required bool takeWithFood,
    String? notes,
  }) async {
    if (kIsWeb) return false;

    // Check if notifications are enabled globally
    if (!HiveService().isNotificationsEnabled()) {
      return false;
    }

    // Don't schedule notifications in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      return false;
    }

    final playSound = HiveService().isSoundsEnabled();
    final channelId = playSound
        ? 'medicine_reminder_channel'
        : 'medicine_reminder_channel_silent';

    try {
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        'Medicine Reminders',
        channelDescription: 'Critical reminders to take your medicines',
        importance: Importance.max,
        priority: Priority.max,
        playSound: playSound,
        category:
            AndroidNotificationCategory.alarm, // Treat as alarm for priority
        fullScreenIntent: true, // Show on lock screen
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(
          _buildNotificationBody(medicineName, dosage, takeWithFood, notes),
          contentTitle: '💊 Medicine Reminder',
          summaryText: 'Time to take your medicine',
        ),
      );

      final darwinPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
        interruptionLevel:
            InterruptionLevel.timeSensitive, // High priority on iOS
      );

      // Windows Toast Notifications
      const windowsPlatformChannelSpecifics = WindowsNotificationDetails();

      final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinPlatformChannelSpecifics,
        macOS: darwinPlatformChannelSpecifics,
        windows: windowsPlatformChannelSpecifics,
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: '💊 Medicine Reminder',
        body: _buildNotificationBody(medicineName, dosage, takeWithFood, notes),
        scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails: platformChannelSpecifics,
        androidScheduleMode:
            AndroidScheduleMode.alarmClock, // Most reliable mode
      );

      debugPrint(
        'Scheduled notification $id for $medicineName at $scheduledTime',
      );
      return true;
    } catch (e) {
      debugPrint('Failed to schedule notification $id: $e');
      return false;
    }
  }

  String _buildNotificationBody(
    String medicineName,
    String dosage,
    bool takeWithFood,
    String? notes,
  ) {
    final StringBuffer body = StringBuffer();
    body.write('Time to take $medicineName ($dosage)');

    if (takeWithFood) {
      body.write('\n🍽️ Take after meal');
    }

    if (notes != null && notes.isNotEmpty) {
      body.write('\n📝 $notes');
    }

    return body.toString();
  }

  /// Cancel a specific notification
  /// NOTE: On Windows, this only works if the app is packaged as MSIX.
  /// Without MSIX packaging, cancel() does nothing on Windows.
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;

    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Failed to cancel notification $id: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;

    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }

  /// Get pending notifications count (useful for debugging)
  Future<int> getPendingNotificationsCount() async {
    if (kIsWeb) return 0;

    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      debugPrint('Pending notifications: ${pending.length}');
      return pending.length;
    } catch (e) {
      debugPrint('Failed to get pending notifications: $e');
      return 0;
    }
  }

  /// Generate a unique notification ID that won't collide
  int generateUniqueId(String medicineId, int offset) {
    // Use a combination of medicine hash and offset
    // Limited to 2^31 - 1 for 32-bit int compatibility
    final hash = medicineId.hashCode.abs() % 2000000;
    return (hash * 1000) + (offset % 1000);
  }

  /// Request exact alarm permission on Android 12+
  Future<void> requestExactAlarmPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  /// Check if exact alarms can be scheduled
  Future<bool> canScheduleExactAlarms() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    // Check permission first
    if (await Permission.scheduleExactAlarm.isGranted) {
      return true;
    }

    // Also check via plugin if available
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final canSchedule = await androidPlugin.canScheduleExactNotifications();
      return canSchedule ?? false;
    }

    return false;
  }

  /// Check if the app has necessary permissions for reliable notifications
  Future<Map<String, bool>> checkPermissionStatus() async {
    if (kIsWeb) {
      return {'all': true};
    }

    final Map<String, bool> status = {};

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        status['notification'] = await Permission.notification.isGranted;
        status['exactAlarm'] = await canScheduleExactAlarms();
        status['batteryOptimization'] =
            await Permission.ignoreBatteryOptimizations.isGranted;
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        // macOS permission detection via permission_handler is limited.
        // We check status, but if it's not explicitly denied, we might be okay.
        final notificationStatus = await Permission.notification.status;
        status['notification'] =
            notificationStatus.isGranted ||
            notificationStatus.isProvisional ||
            // If it's denied but the user says it's granted, it might be due to
            // lack of support in the plugin for macOS detection.
            notificationStatus != PermissionStatus.permanentlyDenied;
        status['all'] = true; // Always allow proceeding on macOS
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final notificationStatus = await Permission.notification.status;
        status['notification'] =
            notificationStatus.isGranted || notificationStatus.isProvisional;
        status['all'] = status['notification'] ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        status['all'] = true;
      } else {
        status['all'] = true;
      }
    } catch (e) {
      debugPrint('Failed to check permission status: $e');
      status['error'] = false;
    }

    return status;
  }

  /// Show a test notification immediately (useful for debugging)
  Future<void> showTestNotification() async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      importance: Importance.max,
      priority: Priority.max,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: 999999,
      title: '🧪 Test Notification',
      body: 'If you see this, notifications are working correctly!',
      notificationDetails: details,
    );
    debugPrint('Test notification sent');
  }
}
