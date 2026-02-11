import 'dart:io';
import 'dart:ui';

import 'package:ausadhi_khau/blocs/medicine/medicine_bloc.dart';
import 'package:ausadhi_khau/blocs/medicine/medicine_event.dart';
import 'package:ausadhi_khau/blocs/theme_bloc.dart';
import 'package:ausadhi_khau/models/medicine.dart';
import 'package:ausadhi_khau/repositories/medicine_repository.dart';
import 'package:ausadhi_khau/screens/add_medicine_screen.dart';
import 'package:ausadhi_khau/screens/calendar_screen.dart';
import 'package:ausadhi_khau/screens/data_transfer_screen.dart';
import 'package:ausadhi_khau/screens/home_screen.dart';
import 'package:ausadhi_khau/screens/insights_screen.dart';
import 'package:ausadhi_khau/screens/onboarding_screen.dart';
import 'package:ausadhi_khau/screens/settings_screen.dart';
import 'package:ausadhi_khau/screens/shell_screen.dart';
import 'package:ausadhi_khau/services/background_task_service.dart';
import 'package:ausadhi_khau/services/desktop_service.dart';
import 'package:ausadhi_khau/services/hive_service.dart';
import 'package:ausadhi_khau/services/notification_service.dart';
import 'package:ausadhi_khau/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Initialize Hive (local storage) - MUST be before DesktopService
  // because DesktopService reads auto-startup setting from Hive
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize desktop window/tray service (uses Hive for settings)
  await DesktopService().initialize();

  // Initialize window manager first for desktop platforms
  if (!UniversalPlatform.isWeb &&
      (UniversalPlatform.isWindows ||
          UniversalPlatform.isLinux ||
          UniversalPlatform.isMacOS)) {
    try {
      await windowManager.ensureInitialized();

      // Check if launched with --hidden argument
      final bool isHiddenLaunch = Platform.executableArguments.contains(
        '--hidden',
      );

      // Configure window options
      final windowOptions = WindowOptions(
        title: 'Ausadhi Khau',
        minimumSize: const Size(482.0, 655.0),
        center: true,
        // If hidden launch, don't show in dock/taskbar
        skipTaskbar: isHiddenLaunch,
      );

      // Wait until ready
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        if (!isHiddenLaunch) {
          await windowManager.show();
          await windowManager.focus();
        } else {
          // Explicitly hide on startup if launched hidden
          await windowManager.hide();
          debugPrint('Silent startup detected - staying minimized to tray');
        }
        // This is critical for minimizing to tray on close
        await windowManager.setPreventClose(true);
      });
    } catch (e) {
      debugPrint('Window manager initialization failed: $e');
    }
  }

  // Initialize notification service
  await NotificationService().initialize();

  // Initialize background task service for periodic notification refresh
  await BackgroundTaskService().initialize();
  await BackgroundTaskService().schedulePeriodicRefresh();

  // Refresh notifications on app start (ensures they're up to date)
  await MedicineRepository().refreshAllNotifications();

  // Get onboarding status
  final bool showOnboarding = !hiveService.isOnboardingCompleted();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc(hiveService)..add(LoadTheme()),
        ),
        BlocProvider(
          create: (context) =>
              MedicineBloc(repository: MedicineRepository())
                ..add(LoadMedicines()),
        ),
      ],
      child: MedicineReminderApp(showOnboarding: showOnboarding),
    ),
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// App lifecycle observer to refresh notifications when app resumes
class AppLifecycleObserver extends WidgetsBindingObserver {
  final MedicineBloc bloc;

  AppLifecycleObserver(this.bloc);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh notifications when app comes to foreground
      debugPrint('App resumed - refreshing notifications');
      bloc.add(RescheduleNotificationsEvent());
    }
  }
}

class MedicineReminderApp extends StatefulWidget {
  final bool showOnboarding;
  const MedicineReminderApp({super.key, required this.showOnboarding});

  @override
  State<MedicineReminderApp> createState() => _MedicineReminderAppState();
}

class _MedicineReminderAppState extends State<MedicineReminderApp> {
  late final GoRouter _router;
  late final AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: widget.showOnboarding ? '/onboarding' : '/',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/add',
          builder: (context, state) {
            // Accept DateTime as extra to pre-fill start date from calendar
            final initialStartDate = state.extra as DateTime?;
            return AddMedicineScreen(
              initialStartDate: initialStartDate,
            );
          },
        ),
        GoRoute(
          path: '/edit',
          builder: (context, state) {
            final medicine = state.extra as Medicine?;
            return AddMedicineScreen(medicine: medicine);
          },
        ),
        GoRoute(
          path: '/export',
          builder: (context, state) => const ExportDataScreen(),
        ),
        GoRoute(
          path: '/import',
          builder: (context, state) => const ImportDataScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ShellScreen(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/calendar',
                  builder: (context, state) => const CalendarScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/insights',
                  builder: (context, state) => const InsightsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    // Initialize the lifecycle observer
    _lifecycleObserver = AppLifecycleObserver(context.read<MedicineBloc>());
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: 'Ausadhi Khau',
          debugShowCheckedModeBanner: false,
          scrollBehavior: AppScrollBehavior(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}
