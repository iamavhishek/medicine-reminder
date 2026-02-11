import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:medicine_remainder_app/repositories/medicine_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:window_manager/window_manager.dart';

class DesktopService extends WindowListener with TrayListener {
  static final DesktopService _instance = DesktopService._internal();
  factory DesktopService() => _instance;
  DesktopService._internal();

  bool _isInitialized = false;

  /// Global key to access the navigator for showing dialogs
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    if (_isInitialized) return;
    if (UniversalPlatform.isWeb ||
        !(UniversalPlatform.isWindows ||
            UniversalPlatform.isMacOS ||
            UniversalPlatform.isLinux)) {
      return;
    }

    // windowManager.ensureInitialized() is called in main.dart
    windowManager.addListener(this);
    trayManager.addListener(this);

    // Prevent default close behavior
    await windowManager.setPreventClose(true);

    // Initialize launch at startup (wrapped in try-catch to prevent crashes)
    try {
      await _initLaunchAtStartup();
    } catch (e) {
      debugPrint('Failed to initialize launch at startup (non-fatal): $e');
    }

    _isInitialized = true;
    debugPrint('DesktopService initialized');

    await _setupTray();
  }

  /// Initialize the launch_at_startup package
  Future<void> _initLaunchAtStartup() async {
    final packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
      packageName: 'np.com.abhishekd.medRemind',
    );

    // Always enable by default
    await launchAtStartup.enable();
    debugPrint('DesktopService: Launch at startup enabled by default');

    // Setup periodic refresh for Desktop
    // Since Desktop doesn't have Workmanager, we use a simple Timer
    // that runs as long as the app is in the tray.
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    // Refresh every 12 hours
    Timer.periodic(const Duration(hours: 12), (timer) async {
      debugPrint('DesktopService: Periodic background refresh triggerred');
      try {
        await MedicineRepository().refreshAllNotifications();
      } catch (e) {
        debugPrint('DesktopService: Periodic refresh failed: $e');
      }
    });
  }

  /// Check if auto startup is currently enabled
  Future<bool> isAutoStartupEnabled() async {
    return true; // Always true now
  }

  Future<void> _setupTray() async {
    try {
      // On Windows, we need to use an .ico file for best results
      // For now, use the PNG asset, but note: proper Windows icons should be .ico
      String iconPath = 'assets/images/tray_icon.png';

      // For Windows, check if we're running from an MSIX package
      // and adjust the path accordingly
      if (UniversalPlatform.isWindows) {
        // When packaged as MSIX, assets are in a different location
        final exeDir = File(Platform.resolvedExecutable).parent.path;
        final msixIconPath =
            '$exeDir/data/flutter_assets/assets/images/tray_icon.png';
        if (File(msixIconPath).existsSync()) {
          iconPath = msixIconPath;
        }
      }

      await trayManager.setIcon(iconPath);
      await trayManager.setToolTip('Medicine Reminder');

      final Menu menu = Menu(
        items: [
          MenuItem(
            key: 'show_window',
            label: 'Show App',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'exit_app',
            label: 'Exit',
          ),
        ],
      );
      await trayManager.setContextMenu(menu);
      debugPrint('DesktopService: Tray setup complete');
    } catch (e) {
      debugPrint('Failed to setup tray: $e');
    }
  }

  /// Dispose the desktop service - call this when the app is closing
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      windowManager.removeListener(this);
      trayManager.removeListener(this);
      await trayManager.destroy();
      _isInitialized = false;
      debugPrint('DesktopService disposed');
    } catch (e) {
      debugPrint('Failed to dispose DesktopService: $e');
    }
  }

  /// Show exit confirmation dialog
  Future<bool> showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Exit Application?'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Closing the app completely may disable medicine reminders.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text(
              'To keep receiving reminders, use "Minimize to Tray" instead. '
              'The app will continue running in the background.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              await windowManager.hide();
              await windowManager.setSkipTaskbar(true);
            },
            child: const Text('Minimize to Tray'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Exit Anyway'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Request to exit the app - shows confirmation dialog
  Future<void> requestExit(BuildContext context) async {
    final shouldExit = await showExitConfirmation(context);
    if (shouldExit) {
      await windowManager.destroy();
    }
  }

  @override
  void onWindowClose() async {
    final bool isPreventClose = await windowManager.isPreventClose();
    debugPrint('Window close requested. preventClose: $isPreventClose');
    if (isPreventClose) {
      await windowManager.hide();
      // On macOS, this hides the dock icon. On Windows, it hides the taskbar icon.
      await windowManager.setSkipTaskbar(true);
      debugPrint('Window hidden (minimized to tray)');
    }
  }

  @override
  void onTrayIconMouseDown() async {
    await windowManager.setSkipTaskbar(false);
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      await windowManager.setSkipTaskbar(false);
      await windowManager.show();
      await windowManager.focus();
    } else if (menuItem.key == 'exit_app') {
      // For tray menu exit, just exit directly (user explicitly chose to exit)
      await windowManager.destroy();
    }
  }
}
