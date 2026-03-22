import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../models/creator.dart' show PriceRange;
import '../data/mock_data.dart';
import '../providers/creator_provider.dart';
import '../screens/directory/directory_screen.dart';
import '../screens/dashboard/finder_dashboard.dart';
import '../screens/dashboard/creative_dashboard.dart';
import '../screens/admin/admin_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  late final AnimationController _tabFade;

  @override
  void initState() {
    super.initState();
    _tabFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _tabFade.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (index == _navIndex) return;
    _tabFade.reverse().then((_) {
      if (!mounted) return;
      setState(() => _navIndex = index);
      _tabFade.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isGuest = user.isGuest;
    final isAdmin = user.role == UserRole.admin;
    final tabs = <_NavTab>[
      const _NavTab(Icons.explore_outlined, Icons.explore, 'Directory'),
      if (!isGuest) const _NavTab(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
      if (!isGuest && isAdmin) const _NavTab(Icons.admin_panel_settings_outlined, Icons.admin_panel_settings, 'Admin'),
    ];

    final screens = <Widget>[
      const DirectoryScreen(),
      if (!isGuest)
        user.role == UserRole.creative
            ? const CreativeDashboard()
            : const FinderDashboard(),
      if (!isGuest && isAdmin) const AdminScreen(),
    ];

    final wide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      // ─── APP BAR ────────────────────────
      appBar: AppBar(
        toolbarHeight: 60,
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Image.asset(
                'assets/brand/kelelelogo25-black-web.png',
                height: 48,
                filterQuality: FilterQuality.medium,
              ),
            ),
            if (wide)
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: tabs.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: _NavButton(
                            label: e.value.label,
                            active: _navIndex == e.key,
                            onTap: () => _switchTab(e.key),
                          ),
                        )).toList(),
                  ),
                ),
              )
            else
              const Spacer(),
          ],
        ),
        actions: [
          if (isGuest)
            // Guest: sign-up prompt
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  ref.read(isGuestProvider.notifier).state = false;
                  if (useMockData) {
                    ref.read(mockAuthProvider.notifier).logout();
                  } else {
                    await ref.read(authServiceProvider).signOut();
                  }
                },
                icon: const Icon(Icons.person_add_outlined, size: 16),
                label: const Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KeleleColors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: const StadiumBorder(),
                  elevation: 0,
                  textStyle: GoogleFonts.spaceGrotesk(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            // Logged-in user menu
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
                              fontSize: 12,
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
                              fontSize: 14, color: KeleleColors.grayMid)),
                      Text(
                          user.role == UserRole.admin
                              ? 'Admin'
                              : user.role == UserRole.creative
                                  ? 'Creative'
                                  : 'Finder',
                          style: TextStyle(
                              fontSize: 13,
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
              onSelected: (v) async {
                if (v == 'logout') {
                  ref.read(isGuestProvider.notifier).state = false;
                  if (useMockData) {
                    ref.read(mockAuthProvider.notifier).logout();
                  } else {
                    await ref.read(authServiceProvider).signOut();
                  }
                }
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: KeleleColors.grayBorder),
        ),
      ),

      // ─── BODY ───────────────────────────
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final showRails = w > 1400;
          final railWidth = w > 1800 ? 280.0 : 200.0;

          final content = FadeTransition(
            opacity: _tabFade,
            child: IndexedStack(
              index: _navIndex.clamp(0, screens.length - 1),
              children: screens,
            ),
          );

          if (!showRails) return content;

          return Row(
            children: [
              _LeftRail(width: railWidth, navIndex: _navIndex, onSwitchTab: _switchTab),
              Expanded(child: content),
              _RightRail(width: railWidth),
            ],
          );
        },
      ),

      // ─── BOTTOM NAV (mobile) ────────────
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _navIndex.clamp(0, tabs.length - 1),
              onDestinationSelected: _switchTab,
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

// ─── LEFT RAIL: Filters ──────────────────────────
class _LeftRail extends ConsumerWidget {
  final double width;
  final int navIndex;
  final void Function(int) onSwitchTab;
  const _LeftRail({required this.width, required this.navIndex, required this.onSwitchTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSkill = ref.watch(selectedSkillProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);
    final selectedLevel = ref.watch(selectedLevelProvider);
    final selectedPrice = ref.watch(selectedPriceProvider);
    final locations = ref.watch(locationsProvider);

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: KeleleColors.grayBorder, width: 0.5),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            if (navIndex == 0) ...[
              _FilterSection(
                title: 'SKILL',
                initiallyExpanded: true,
                activeCount: selectedSkill != null ? 1 : 0,
                children: [
                  _FilterChip(
                    label: 'All Skills',
                    active: selectedSkill == null,
                    onTap: () =>
                        ref.read(selectedSkillProvider.notifier).state = null,
                  ),
                  ...skillsList.map((s) => _FilterChip(
                        label: s,
                        active: selectedSkill == s,
                        onTap: () => ref
                            .read(selectedSkillProvider.notifier)
                            .state = selectedSkill == s ? null : s,
                      )),
                ],
              ),

              _FilterSection(
                title: 'LOCATION',
                activeCount: selectedLocation != null ? 1 : 0,
                children: [
                  _FilterChip(
                    label: 'All Locations',
                    active: selectedLocation == null,
                    onTap: () =>
                        ref.read(selectedLocationProvider.notifier).state = null,
                  ),
                  ...locations.map((loc) => _FilterChip(
                        label: loc,
                        active: selectedLocation == loc,
                        icon: Icons.location_on_outlined,
                        onTap: () => ref
                            .read(selectedLocationProvider.notifier)
                            .state = selectedLocation == loc ? null : loc,
                      )),
                ],
              ),

              _FilterSection(
                title: 'EXPERIENCE',
                activeCount: selectedLevel != null ? 1 : 0,
                children: [
                  _FilterChip(
                    label: 'All Levels',
                    active: selectedLevel == null,
                    onTap: () =>
                        ref.read(selectedLevelProvider.notifier).state = null,
                  ),
                  ...[
                    (3, 'Expert'),
                    (2, 'Skilled'),
                    (1, 'Emerging'),
                  ].map((e) => _FilterChip(
                        label: e.$2,
                        active: selectedLevel == e.$1,
                        onTap: () => ref
                            .read(selectedLevelProvider.notifier)
                            .state = selectedLevel == e.$1 ? null : e.$1,
                      )),
                ],
              ),

              _FilterSection(
                title: 'PRICE RANGE',
                activeCount: selectedPrice != null ? 1 : 0,
                children: [
                  _FilterChip(
                    label: 'Any Price',
                    active: selectedPrice == null,
                    onTap: () =>
                        ref.read(selectedPriceProvider.notifier).state = null,
                  ),
                  ...[
                    (PriceRange.budget, 'Budget'),
                    (PriceRange.mid, 'Mid-range'),
                    (PriceRange.premium, 'Premium'),
                  ].map((e) => _FilterChip(
                        label: e.$2,
                        active: selectedPrice == e.$1,
                        onTap: () => ref
                            .read(selectedPriceProvider.notifier)
                            .state = selectedPrice == e.$1 ? null : e.$1,
                      )),
                ],
              ),
            ],

            // Quick links (non-directory tabs)
            if (navIndex != 0)
              _FilterSection(
                title: 'QUICK LINKS',
                initiallyExpanded: true,
                children: [
                  _FilterChip(
                    label: 'Browse Directory',
                    active: false,
                    icon: Icons.explore_outlined,
                    onTap: () => onSwitchTab(0),
                  ),
                  _FilterChip(
                    label: 'My Bookmarks',
                    active: false,
                    icon: Icons.bookmark_outline,
                    onTap: () => onSwitchTab(1),
                  ),
                ],
              ),

            // Stats (always visible)
            _FilterSection(
              title: 'STATS',
              initiallyExpanded: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: [
                    _StatRow('Total Creators', '${ref.watch(creatorsProvider).length}'),
                    _StatRow('Verified', '${ref.watch(verifiedCreatorsProvider).length}'),
                    _StatRow('Skills', '${skillsList.length}'),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatefulWidget {
  final String title;
  final bool initiallyExpanded;
  final int activeCount;
  final List<Widget> children;

  const _FilterSection({
    required this.title,
    this.initiallyExpanded = false,
    this.activeCount = 0,
    required this.children,
  });

  @override
  State<_FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<_FilterSection>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _anim;
  late final Animation<double> _heightFactor;
  late final Animation<double> _iconTurn;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: _expanded ? 1.0 : 0.0,
    );
    _heightFactor = _anim.drive(CurveTween(curve: Curves.easeInOut));
    _iconTurn = _anim.drive(Tween(begin: 0.0, end: 0.5));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(widget.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: KeleleColors.grayMid,
                          )),
                      if (widget.activeCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: KeleleColors.pink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${widget.activeCount}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                ),
                RotationTransition(
                  turns: _iconTurn,
                  child: Icon(Icons.expand_more,
                      size: 16, color: KeleleColors.grayMid),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedBuilder(
            animation: _heightFactor,
            builder: (context, child) => Align(
              alignment: Alignment.topCenter,
              heightFactor: _heightFactor.value,
              child: child,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(children: widget.children),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final IconData? icon;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.active,
      required this.onTap,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2, left: 16, right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: active ? KeleleColors.pinkGlow : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: active ? KeleleColors.pink : KeleleColors.grayMid),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? KeleleColors.pink : KeleleColors.dark,
                    )),
              ),
              if (active)
                Icon(Icons.check, size: 14, color: KeleleColors.pink),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: KeleleColors.grayMid)),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── RIGHT RAIL: Ads & Announcements ─────────────
class _RightRail extends StatelessWidget {
  final double width;
  const _RightRail({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: KeleleColors.grayBorder, width: 0.5),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ad placeholder 1
            _AdCard(
              title: 'Multimedia Meetup',
              subtitle: 'Kampala, March 2026',
              color: KeleleColors.pink,
              icon: Icons.event,
            ),
            const SizedBox(height: 12),
            // Ad placeholder 2
            _AdCard(
              title: 'Creator Spotlight',
              subtitle: 'Featured creatives this month',
              color: const Color(0xFF6C5CE7),
              icon: Icons.auto_awesome,
            ),
            const SizedBox(height: 12),
            // Ad placeholder 3
            _AdCard(
              title: 'Hire with Kelele',
              subtitle: 'Post a brief, find talent',
              color: const Color(0xFF00B894),
              icon: Icons.work_outline,
            ),
            const SizedBox(height: 24),
            // Announcement
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KeleleColors.grayLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ANNOUNCEMENTS',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: KeleleColors.grayMid)),
                  const SizedBox(height: 10),
                  Text('New skill category: UI/UX Design is now live!',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text('We just added 5 new verified creators this week.',
                      style: TextStyle(fontSize: 13, color: KeleleColors.grayMid)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final String title, subtitle;
  final Color color;
  final IconData icon;
  const _AdCard(
      {required this.title,
      required this.subtitle,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(height: 10),
          Text(title,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
