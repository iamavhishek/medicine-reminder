import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicine_remainder_app/blocs/medicine/medicine_bloc.dart';
import 'package:medicine_remainder_app/blocs/medicine/medicine_event.dart';
import 'package:medicine_remainder_app/blocs/theme_bloc.dart';
import 'package:medicine_remainder_app/services/desktop_service.dart';
import 'package:medicine_remainder_app/services/hive_service.dart';
import 'package:medicine_remainder_app/services/notification_service.dart';
import 'package:medicine_remainder_app/widgets/settings/settings_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notificationsEnabled;
  late bool _soundsEnabled;
  bool _isDesktopPlatform = false;
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = HiveService().isNotificationsEnabled();
    _soundsEnabled = HiveService().isSoundsEnabled();
    _isDesktopPlatform =
        !UniversalPlatform.isWeb &&
        (UniversalPlatform.isWindows ||
            UniversalPlatform.isMacOS ||
            UniversalPlatform.isLinux);
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() => _version = packageInfo.version);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context, isDesktop),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 24),
              child: Column(
                children: [
                  const SettingsSectionHeader(title: 'APPEARANCE'),
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      return SettingsCard(
                        children: [
                          _buildThemeOption(
                            context,
                            'System',
                            ThemeMode.system,
                            state.themeMode,
                            Icons.brightness_auto_outlined,
                          ),
                          const SettingsDivider(),
                          _buildThemeOption(
                            context,
                            'Light',
                            ThemeMode.light,
                            state.themeMode,
                            Icons.light_mode_outlined,
                          ),
                          const SettingsDivider(),
                          _buildThemeOption(
                            context,
                            'Dark',
                            ThemeMode.dark,
                            state.themeMode,
                            Icons.dark_mode_outlined,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const SettingsSectionHeader(title: 'GENERAL'),
                  SettingsCard(
                    children: [
                      SettingsSwitchTile(
                        title: 'Enable Notifications',
                        subtitle: 'Receive reminders for your medications',
                        value: _notificationsEnabled,
                        onChanged: (val) async {
                          if (val) {
                            final granted = await NotificationService()
                                .requestPermissions();
                            if (!granted && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'NOTIFICATION PERMISSION DENIED. PLEASE ENABLE IN SYSTEM SETTINGS.',
                                  ),
                                ),
                              );
                              return;
                            }
                          }
                          setState(() => _notificationsEnabled = val);
                          await HiveService().setNotificationsEnabled(val);
                          if (context.mounted) {
                            context.read<MedicineBloc>().add(
                              RescheduleNotificationsEvent(),
                            );
                          }
                        },
                        icon: Icons.notifications_outlined,
                      ),
                      const SettingsDivider(),
                      SettingsSwitchTile(
                        title: 'Sounds',
                        subtitle: 'Play sounds with notifications',
                        value: _soundsEnabled,
                        onChanged: (val) async {
                          setState(() => _soundsEnabled = val);
                          await HiveService().setSoundsEnabled(val);
                          if (context.mounted) {
                            context.read<MedicineBloc>().add(
                              RescheduleNotificationsEvent(),
                            );
                          }
                        },
                        icon: Icons.volume_up_outlined,
                      ),
                      const SettingsDivider(),
                      SettingsActionTile(
                        title: 'Test Notification',
                        subtitle: 'Send a test alert immediately',
                        icon: Icons.science_outlined,
                        color: Colors.purple,
                        onTap: () async {
                          await NotificationService().showTestNotification();
                        },
                      ),
                    ],
                  ),

                  // Desktop-specific settings
                  if (_isDesktopPlatform) ...[
                    const SizedBox(height: 32),
                    const SettingsSectionHeader(title: 'DESKTOP'),
                    SettingsCard(
                      children: [
                        SettingsActionTile(
                          title: 'Exit Application',
                          subtitle:
                              'Close the app completely (may disable reminders)',
                          icon: Icons.exit_to_app_outlined,
                          color: Colors.orange,
                          onTap: () => DesktopService().requestExit(context),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),
                  const SettingsSectionHeader(title: 'DATA TRANSFER'),
                  SettingsCard(
                    children: [
                      SettingsActionTile(
                        title: 'Create Backup',
                        subtitle: 'Save data to a file',
                        icon: Icons.save_alt_rounded,
                        color: Colors.blue,
                        onTap: () => context.push('/export'),
                      ),
                      const SettingsDivider(),
                      SettingsActionTile(
                        title: 'Restore Backup',
                        subtitle: 'Import data from a file',
                        icon: Icons.restore_page_rounded,
                        color: Colors.green,
                        onTap: () => context.push('/import'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const SettingsSectionHeader(title: 'DATA & PRIVACY'),
                  SettingsCard(
                    children: [
                      SettingsActionTile(
                        title: 'Clear All Data',
                        subtitle:
                            'Permanently delete all medicines and history',
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        onTap: () => _showClearDataConfirmation(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const SettingsSectionHeader(title: 'ABOUT'),
                  SettingsCard(
                    children: [
                      SettingsInfoTile(
                        title: 'Version',
                        value: _version,
                        icon: Icons.info_outline,
                      ),
                      const SettingsDivider(),
                      SettingsActionTile(
                        title: 'Privacy Policy',
                        icon: Icons.privacy_tip_outlined,
                        onTap: () {},
                      ),
                      const SettingsDivider(),
                      SettingsActionTile(
                        title: 'Terms of Service',
                        icon: Icons.description_outlined,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    ThemeMode mode,
    ThemeMode currentMode,
    IconData icon,
  ) {
    final isSelected = currentMode == mode;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.read<ThemeBloc>().add(ThemeChanged(mode)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 48 : 24,
          isDesktop ? 64 : 48,
          isDesktop ? 48 : 24,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PREFERENCES',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                fontWeight: FontWeight.w800,
                fontSize: isDesktop ? 12 : 10,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'SETTINGS',
              style: TextStyle(
                fontSize: isDesktop ? 32 : 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClearDataConfirmation(BuildContext context) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'ERASE ALL DATA?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: -0.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'This will permanently delete all your medicines and reminder history. This action cannot be undone.',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'ERASE EVERYTHING',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<MedicineBloc>().add(ClearAllMedicinesEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All data has been erased.'.toUpperCase()),
          backgroundColor: theme.colorScheme.onSurface,
        ),
      );
    }
  }
}
