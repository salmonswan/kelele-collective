import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/creator.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/creator_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class CreativeDashboard extends ConsumerStatefulWidget {
  const CreativeDashboard({super.key});

  @override
  ConsumerState<CreativeDashboard> createState() => _CreativeDashboardState();
}

class _CreativeDashboardState extends ConsumerState<CreativeDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final creators = ref.watch(creatorsProvider);
    final myProfile = creators.where((c) => c.email == user?.email).firstOrNull;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: KeleleColors.pink,
                  child: Text(user?.initials ?? '',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome, ${user?.name ?? ''}',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                    Text('Creative Dashboard',
                        style: TextStyle(
                            fontSize: 13, color: KeleleColors.grayMid)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Tabs
            TabBar(
              controller: _tabs,
              labelColor: KeleleColors.pink,
              unselectedLabelColor: KeleleColors.grayMid,
              indicatorColor: KeleleColors.pink,
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Portfolio'),
                Tab(text: 'Vetting'),
              ],
            ),
            const SizedBox(height: 24),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  // Profile tab
                  _ProfileTab(user: user, profile: myProfile),
                  // Portfolio tab
                  _PortfolioTab(profile: myProfile),
                  // Vetting tab
                  _VettingTab(profile: myProfile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final AppUser? user;
  final Creator? profile;
  const _ProfileTab({required this.user, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KeleleColors.grayBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Profile',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            if (profile != null) ...[
              _InfoRow('Name', profile!.name),
              _InfoRow('Email', profile!.email),
              _InfoRow('Location', profile!.location),
              _InfoRow('Primary Skill', profile!.primarySkill),
              _InfoRow('Level', profile!.levelLabel),
              _InfoRow('Price Range', profile!.priceLabel),
              const SizedBox(height: 16),
              Text('Bio', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: KeleleColors.grayMid)),
              const SizedBox(height: 4),
              Text(profile!.bio, style: TextStyle(fontSize: 14, height: 1.6, color: const Color(0xFF555555))),
            ] else
              Text(
                'Your profile will appear here once approved.',
                style: TextStyle(color: KeleleColors.grayMid),
              ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioTab extends StatelessWidget {
  final Creator? profile;
  const _PortfolioTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile == null || profile!.portfolio.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 48, color: KeleleColors.grayBorder),
            const SizedBox(height: 12),
            Text('No portfolio items yet',
                style: TextStyle(color: KeleleColors.grayMid)),
          ],
        ),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: profile!.portfolio.length,
      itemBuilder: (ctx, i) {
        final p = profile!.portfolio[i];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KeleleColors.grayBorder),
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(gradient: p.cover),
                    child: Center(
                      child: Text(p.title.split(' ').map((w) => w.isNotEmpty ? w[0] : '').join(),
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.15))),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(p.skill, style: TextStyle(fontSize: 11, color: KeleleColors.grayMid)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VettingTab extends StatelessWidget {
  final Creator? profile;
  const _VettingTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KeleleColors.grayBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vetting Status',
                style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (profile != null) ...[
              StatusBadge(status: profile!.status),
              if (profile!.reviewNotes.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Reviewer Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: KeleleColors.grayMid)),
                const SizedBox(height: 6),
                Text(profile!.reviewNotes, style: const TextStyle(fontSize: 14, height: 1.6)),
              ],
              if (profile!.reviewedBy.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Reviewed by ${profile!.reviewedBy} on ${profile!.reviewedAt}',
                    style: TextStyle(fontSize: 12, color: KeleleColors.grayMid)),
              ],
            ] else
              Text('No vetting information available.',
                  style: TextStyle(color: KeleleColors.grayMid)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: KeleleColors.grayMid)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
