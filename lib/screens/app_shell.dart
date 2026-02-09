import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../screens/directory/directory_screen.dart';
import '../screens/dashboard/finder_dashboard.dart';
import '../screens/dashboard/creative_dashboard.dart';
import '../screens/admin/admin_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox.shrink();

    final isAdmin = user.role == UserRole.admin;
    final tabs = <_NavTab>[
      const _NavTab(Icons.explore_outlined, Icons.explore, 'Directory'),
      const _NavTab(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
      if (isAdmin) const _NavTab(Icons.admin_panel_settings_outlined, Icons.admin_panel_settings, 'Admin'),
    ];

    final screens = <Widget>[
      const DirectoryScreen(),
      user.role == UserRole.creative
          ? const CreativeDashboard()
          : const FinderDashboard(),
      if (isAdmin) const AdminScreen(),
    ];

    final wide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      // ─── APP BAR ────────────────────────
      appBar: AppBar(
        toolbarHeight: 60,
        title: Row(
          children: [
            Text('Kelele',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            Text('.',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: KeleleColors.pink)),
            if (wide) ...[
              const SizedBox(width: 32),
              ...tabs.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _NavButton(
                      label: e.value.label,
                      active: _navIndex == e.key,
                      onTap: () => setState(() => _navIndex = e.key),
                    ),
                  )),
            ],
          ],
        ),
        actions: [
          // User menu
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: KeleleColors.grayLight,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: KeleleColors.pink,
                    child: Text(user.initials,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                  if (wide) ...[
                    const SizedBox(width: 8),
                    Text(user.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more,
                      size: 18, color: KeleleColors.grayMid),
                ],
              ),
            ),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black)),
                    Text(user.email,
                        style: TextStyle(
                            fontSize: 12, color: KeleleColors.grayMid)),
                    Text(
                        user.role == UserRole.admin
                            ? 'Admin'
                            : user.role == UserRole.creative
                                ? 'Creative'
                                : 'Finder',
                        style: TextStyle(
                            fontSize: 11,
                            color: KeleleColors.pink,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: KeleleColors.grayMid),
                    const SizedBox(width: 10),
                    const Text('Sign Out'),
                  ],
                ),
              ),
            ],
            onSelected: (v) {
              if (v == 'logout') ref.read(authProvider.notifier).logout();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: KeleleColors.grayBorder),
        ),
      ),

      // ─── BODY ───────────────────────────
      body: IndexedStack(
        index: _navIndex.clamp(0, screens.length - 1),
        children: screens,
      ),

      // ─── BOTTOM NAV (mobile) ────────────
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _navIndex.clamp(0, tabs.length - 1),
              onDestinationSelected: (i) => setState(() => _navIndex = i),
              height: 64,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              indicatorColor: KeleleColors.pinkGlow,
              destinations: tabs
                  .map((t) => NavigationDestination(
                        icon: Icon(t.icon),
                        selectedIcon:
                            Icon(t.activeIcon, color: KeleleColors.pink),
                        label: t.label,
                      ))
                  .toList(),
            ),
    );
  }
}

class _NavTab {
  final IconData icon, activeIcon;
  final String label;
  const _NavTab(this.icon, this.activeIcon, this.label);
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavButton(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? KeleleColors.grayLight : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? KeleleColors.dark : KeleleColors.grayMid,
            )),
      ),
    );
  }
}
