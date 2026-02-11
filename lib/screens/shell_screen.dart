import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicine_remainder_app/widgets/main_sidebar.dart';

class ShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    // We can get the current path from the shell itself if needed, or by shell.currentIndex
    // But MainSidebar expects a path string. StatefulNavigationShell doesn't expose full path simply.
    // However, MainSidebar logic is primarily for highlighting.
    // We can map index back to path, or update MainSidebar to accept index.
    // For now, let's map index to path to keep MainSidebar changes minimal.
    final currentPath = _getPathFromIndex(navigationShell.currentIndex);

    if (!isDesktop) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.onSurface,
          unselectedItemColor: theme.colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'DASHBOARD',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'CALENDAR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'INSIGHTS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'SETTINGS',
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          MainSidebar(
            currentPath: currentPath,
            onNavigate: (path) {
              final index = _getIndexFromPath(path);
              _onItemTapped(index, context);
            },
          ),
          Container(
            width: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  String _getPathFromIndex(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return '/calendar';
      case 2:
        return '/insights';
      case 3:
        return '/settings';
      default:
        return '/';
    }
  }

  int _getIndexFromPath(String path) {
    if (path.startsWith('/calendar')) return 1;
    if (path.startsWith('/insights')) return 2;
    if (path.startsWith('/settings')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
