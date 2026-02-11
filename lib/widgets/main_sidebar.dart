import 'package:flutter/material.dart';

class MainSidebar extends StatelessWidget {
  final String currentPath;
  final Function(String) onNavigate;

  const MainSidebar({
    super.key,
    required this.currentPath,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 260,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'COMPANION',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 48),
          _buildSidebarItem(
            context,
            Icons.home_filled,
            'DASHBOARD',
            currentPath == '/' || currentPath.startsWith('/edit'),
            onTap: () => onNavigate('/'),
          ),
          _buildSidebarItem(
            context,
            Icons.calendar_month,
            'CALENDAR',
            currentPath == '/calendar',
            onTap: () => onNavigate('/calendar'),
          ),
          _buildSidebarItem(
            context,
            Icons.analytics_outlined,
            'INSIGHTS',
            currentPath == '/insights',
            onTap: () => onNavigate('/insights'),
          ),
          _buildSidebarItem(
            context,
            Icons.settings_outlined,
            'SETTINGS',
            currentPath == '/settings',
            onTap: () => onNavigate('/settings'),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: isActive
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
