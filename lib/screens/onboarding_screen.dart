import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicine_remainder_app/services/hive_service.dart';
import 'package:medicine_remainder_app/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCheckingPermissions = false;

  // Permission states
  bool _notificationGranted = false;
  bool _exactAlarmGranted = false;
  bool _batteryOptimizationGranted = false;

  final List<OnboardingData> _pages = [
    const OnboardingData(
      title: 'NEVER MISS A DOSE',
      description:
          'The simple and effective way to manage your medication schedule with ease.',
      icon: Icons.medication_rounded,
    ),
    const OnboardingData(
      title: 'SMART REMINDERS',
      description:
          'Get notified exactly when it\'s time. We support complex schedules and phases.',
      icon: Icons.notifications_active_rounded,
    ),
    const OnboardingData(
      title: 'STAY ORGANIZED',
      description:
          'Keep track of all your medicines, dosages, and special instructions in one place.',
      icon: Icons.assignment_rounded,
    ),
    const OnboardingData(
      title: 'PERMISSIONS REQUIRED',
      description:
          'To deliver reliable medicine reminders, we need a few permissions.',
      icon: Icons.security_rounded,
      isPermissionPage: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permissions when app resumes (user may have changed settings)
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  /// Check if we need permissions based on platform
  bool get _needsPermissions {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// Check if all required permissions are granted
  bool get _allPermissionsGranted {
    if (!_needsPermissions) return true;

    if (defaultTargetPlatform == TargetPlatform.windows) {
      return true;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _notificationGranted &&
          _exactAlarmGranted &&
          _batteryOptimizationGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _notificationGranted;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      // On macOS, we allow progression even if detection is flaky,
      // as long as the user has been shown the permission page.
      return true;
    }
    return true;
  }

  Future<void> _checkPermissions() async {
    if (!_needsPermissions) return;

    setState(() => _isCheckingPermissions = true);

    try {
      final statusMap = await NotificationService().checkPermissionStatus();

      setState(() {
        _notificationGranted = statusMap['notification'] ?? false;

        if (defaultTargetPlatform == TargetPlatform.android) {
          _exactAlarmGranted = statusMap['exactAlarm'] ?? false;
          _batteryOptimizationGranted =
              statusMap['batteryOptimization'] ?? false;
        }
      });
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }

    setState(() => _isCheckingPermissions = false);
  }

  Future<void> _requestAllPermissions() async {
    setState(() => _isCheckingPermissions = true);

    try {
      await NotificationService().requestPermissions();
      await _checkPermissions();
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }

    setState(() => _isCheckingPermissions = false);
  }

  Future<void> _requestNotificationPermission() async {
    await Permission.notification.request();
    await _checkPermissions();
  }

  Future<void> _requestExactAlarmPermission() async {
    await NotificationService().requestExactAlarmPermission();
    await _checkPermissions();
  }

  Future<void> _requestBatteryOptimization() async {
    await Permission.ignoreBatteryOptimizations.request();
    await _checkPermissions();
  }

  Future<void> _completeOnboarding() async {
    if (!_allPermissionsGranted && _needsPermissions) {
      _showPermissionRequiredDialog();
      return;
    }

    await HiveService().setOnboardingCompleted(true);
    if (!mounted) return;
    context.go('/');
  }

  void _showPermissionRequiredDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'PERMISSIONS REQUIRED',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          'All permissions are required for the app to send you medicine reminders. Please grant all permissions to continue.',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text(
              'OPEN SETTINGS',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 900;
    final isMediumScreen = size.width > 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: isLargeScreen
          ? _buildLargeScreenLayout(context)
          : _buildMobileLayout(context, isMediumScreen),
    );
  }

  /// Large screen layout - side by side design
  Widget _buildLargeScreenLayout(BuildContext context) {
    final theme = Theme.of(context);
    final currentPageData = _pages[_currentPage];

    return Row(
      children: [
        // Left side - Illustration/branding
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo/Brand
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.medication_rounded,
                            color: theme.colorScheme.onSurface,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'MEDICINE\nREMINDER',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            height: 1.2,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Large icon with glassmorphism feel
                    Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        key: ValueKey(_currentPage),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(60),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.03,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.05,
                                  ),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.05,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Icon(
                                  currentPageData.icon,
                                  size: 100,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Spacer(),
                    // Page title on left side
                    Text(
                      currentPageData.title,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentPageData.description,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Page indicators
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => _buildLargeIndicator(index == _currentPage),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Right side - Content/Permissions
        Expanded(
          flex: 4,
          child: Container(
            color: theme.colorScheme.surface,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Skip button
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'SKIP',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (currentPageData.isPermissionPage)
                      _buildPermissionsContent(context, isLargeScreen: true)
                    else
                      _buildStepContent(context, isLargeScreen: true),
                    const Spacer(),
                    // Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage > 0)
                          TextButton.icon(
                            onPressed: () {
                              if (_pageController.hasClients) {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                setState(() => _currentPage--);
                              }
                            },
                            icon: const Icon(Icons.arrow_back_ios_rounded),
                            label: const Text(
                              'BACK',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          )
                        else
                          const SizedBox(),
                        _buildNavigationButton(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile layout - vertical stacked design
  Widget _buildMobileLayout(BuildContext context, bool isMediumScreen) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMediumScreen ? 600 : 500),
        child: Container(
          color: theme.colorScheme.surface,
          child: SafeArea(
            child: Column(
              children: [
                // Skip button - only enabled if permissions granted
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return _buildMobilePage(context, _pages[index]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) =>
                              _buildIndicator(context, index == _currentPage),
                        ),
                      ),
                      _buildNavigationButton(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobilePage(BuildContext context, OnboardingData page) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Gradient icon container
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Icon(
                page.icon,
                size: 70,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 50),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          if (page.isPermissionPage) ...[
            const SizedBox(height: 40),
            _buildPermissionsContent(context, isLargeScreen: false),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPermissionsContent(
    BuildContext context, {
    required bool isLargeScreen,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: isLargeScreen
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (isLargeScreen) ...[
          Text(
            'Required Permissions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Grant these permissions to receive medicine reminders',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
        ],
        // Permission items
        _buildPermissionItem(
          context,
          icon: Icons.notifications_active_rounded,
          title: 'Notifications',
          description: 'Show medicine reminder alerts',
          isGranted: _notificationGranted,
          onRequest: _requestNotificationPermission,
          isLargeScreen: isLargeScreen,
        ),
        const SizedBox(height: 16),
        if (defaultTargetPlatform == TargetPlatform.android) ...[
          _buildPermissionItem(
            context,
            icon: Icons.alarm_rounded,
            title: 'Exact Alarms',
            description: 'Schedule precise reminder times',
            isGranted: _exactAlarmGranted,
            onRequest: _requestExactAlarmPermission,
            isLargeScreen: isLargeScreen,
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            context,
            icon: Icons.battery_saver_rounded,
            title: 'Battery Optimization',
            description: 'Keep reminders working in background',
            isGranted: _batteryOptimizationGranted,
            onRequest: _requestBatteryOptimization,
            isLargeScreen: isLargeScreen,
          ),
          const SizedBox(height: 16),
        ] else if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) ...[
          _buildPermissionItem(
            context,
            icon: Icons.warning_amber_rounded,
            title: 'Critical Alerts',
            description: 'Bypass Do Not Disturb for critical meds',
            isGranted:
                _notificationGranted, // Inherited from general notifications for display
            onRequest: _requestNotificationPermission,
            isLargeScreen: isLargeScreen,
          ),
          const SizedBox(height: 16),
        ],
        // Grant all button
        const SizedBox(height: 8),
        SizedBox(
          width: isLargeScreen ? double.infinity : null,
          child: ElevatedButton.icon(
            onPressed: _isCheckingPermissions ? null : _requestAllPermissions,
            icon: _isCheckingPermissions
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    _allPermissionsGranted
                        ? Icons.check_circle_rounded
                        : Icons.security_rounded,
                    size: 20,
                  ),
            label: Text(
              _allPermissionsGranted ? 'ALL GRANTED' : 'GRANT ALL PERMISSIONS',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _allPermissionsGranted
                  ? const Color(0xFF10B981)
                  : theme.colorScheme.primary,
              foregroundColor: _allPermissionsGranted
                  ? Colors.white
                  : theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        if (!_allPermissionsGranted && _needsPermissions) ...[
          const SizedBox(height: 16),
          Text(
            '* Required permissions must be granted to continue',
            textAlign: isLargeScreen ? TextAlign.start : TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.error.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPermissionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onRequest,
    bool isOptional = false,
    required bool isLargeScreen,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGranted
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : theme.colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGranted
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isGranted
                  ? const Color(0xFF10B981)
                  : theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isOptional)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'OPTIONAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          isGranted
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                )
              : TextButton(
                  onPressed: onRequest,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'GRANT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context, {
    required bool isLargeScreen,
  }) {
    final theme = Theme.of(context);
    final features = [
      {'icon': Icons.schedule_rounded, 'text': 'Flexible scheduling options'},
      {
        'icon': Icons.repeat_rounded,
        'text': 'Daily, weekly, monthly reminders',
      },
      {'icon': Icons.history_rounded, 'text': 'Track your medication history'},
      {'icon': Icons.dark_mode_rounded, 'text': 'Beautiful dark/light themes'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        ...features.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    f['icon'] as IconData,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  f['text'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _pages.length - 1;

    if (isLastPage) {
      return ElevatedButton(
        onPressed: _allPermissionsGranted ? _completeOnboarding : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _allPermissionsGranted
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          foregroundColor: theme.colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _allPermissionsGranted ? 'GET STARTED' : 'GRANT PERMISSIONS',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            if (_allPermissionsGranted) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          if (_pageController.hasClients) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          } else {
            setState(() => _currentPage++);
          }
        },
        icon: Icon(
          Icons.arrow_forward_ios_rounded,
          color: theme.colorScheme.surface,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, bool isActive) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildLargeIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 12),
      height: 6,
      width: isActive ? 40 : 12,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

final class OnboardingData extends Equatable {
  final String title;
  final String description;
  final IconData icon;
  final bool isPermissionPage;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    this.isPermissionPage = false,
  });

  @override
  List<Object> get props => [
    title,
    description,
    icon,
    isPermissionPage,
  ];
}
