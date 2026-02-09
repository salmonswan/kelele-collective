import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/creator.dart';
import '../../providers/creator_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class ProfileScreen extends ConsumerWidget {
  final int creatorId;
  const ProfileScreen({super.key, required this.creatorId});

  String _linkLabel(String url) {
    if (url.contains('behance')) return 'Behance';
    if (url.contains('vimeo')) return 'Vimeo';
    if (url.contains('youtube')) return 'YouTube';
    if (url.contains('figma')) return 'Figma';
    if (url.contains('soundcloud')) return 'SoundCloud';
    if (url.contains('artstation')) return 'ArtStation';
    return 'Web';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creators = ref.watch(creatorsProvider);
    final user = ref.watch(authProvider);
    final bookmarks = ref.watch(bookmarksProvider);
    final c = creators.where((cr) => cr.id == creatorId).firstOrNull;

    if (c == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Creator not found',
                  style: TextStyle(color: KeleleColors.grayMid)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Directory'),
              ),
            ],
          ),
        ),
      );
    }

    final coverGrad = c.portfolio.isNotEmpty
        ? c.portfolio.first.cover
        : const LinearGradient(
            colors: [KeleleColors.dark, KeleleColors.darkSoft]);
    final bookmarked = bookmarks.contains(c.id);

    return Scaffold(
      backgroundColor: KeleleColors.grayLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Back button ──────────────────
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back to directory'),
                    style: TextButton.styleFrom(
                        foregroundColor: KeleleColors.grayMid),
                  ),
                ),
              ),
            ),

            // ─── COVER ────────────────────────
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(gradient: coverGrad),
              child: Center(
                child: Text(c.initials,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 120,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.06))),
              ),
            ),

            // ─── HEADER CARD ──────────────────
            Transform.translate(
              offset: const Offset(0, -60),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: const BoxConstraints(maxWidth: 1000),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KeleleColors.grayBorder),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: LayoutBuilder(builder: (ctx, constraints) {
                        final wide = constraints.maxWidth > 500;
                        final info = Column(
                          crossAxisAlignment: wide
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center,
                          children: [
                            // Name row
                            Wrap(
                              alignment: wide
                                  ? WrapAlignment.start
                                  : WrapAlignment.center,
                              spacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(c.name,
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700)),
                                StatusBadge(status: c.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on,
                                    size: 14, color: KeleleColors.grayMid),
                                const SizedBox(width: 4),
                                Text(c.location,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: KeleleColors.grayMid)),
                                if (c.companyName.isNotEmpty) ...[
                                  Text(' · ',
                                      style: TextStyle(
                                          color: KeleleColors.grayMid)),
                                  Text(c.companyName,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(c.bio,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF555555),
                                    height: 1.7)),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _Tag(c.primarySkill, KeleleColors.pinkGlow,
                                    KeleleColors.pinkDark),
                                ...c.skills
                                    .where((s) => s != c.primarySkill)
                                    .map((s) => _Tag(s, KeleleColors.grayLight,
                                        KeleleColors.grayMid)),
                                _Tag(c.levelLabel, KeleleColors.dark,
                                    Colors.white),
                                _Tag(c.priceLabel, KeleleColors.grayLight,
                                    KeleleColors.grayMid),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.email_outlined,
                                      size: 18),
                                  label: const Text('Send Inquiry'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => ref
                                      .read(bookmarksProvider.notifier)
                                      .toggle(c.id),
                                  icon: Icon(
                                      bookmarked
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 18,
                                      color: bookmarked
                                          ? KeleleColors.pink
                                          : null),
                                  label: Text(bookmarked ? 'Saved' : 'Save'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.share, size: 18),
                                  label: const Text('Share'),
                                ),
                              ],
                            ),
                          ],
                        );

                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: KeleleColors.pink,
                                child: Text(c.initials,
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ),
                              const SizedBox(width: 28),
                              Expanded(child: info),
                            ],
                          );
                        } else {
                          return Column(children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: KeleleColors.pink,
                              child: Text(c.initials,
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ),
                            const SizedBox(height: 16),
                            info,
                          ]);
                        }
                      }),
                    ),
                    // Stats bar
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border(top: BorderSide(color: KeleleColors.grayBorder)),
                      ),
                      child: Row(
                        children: [
                          _StatCell('${c.portfolio.length}', 'Projects'),
                          _StatCell('${c.skills.length}', 'Skills'),
                          _StatCell(c.levelLabel, 'Level'),
                          _StatCell(c.priceLabel, 'Rate'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── CONTACT ──────────────────────
            if (user != null)
              Transform.translate(
                offset: const Offset(0, -44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _ContactCard(Icons.email_outlined, 'Email', c.email),
                        _ContactCard(Icons.phone_outlined, 'Phone', c.phone),
                        if (c.whatsapp.isNotEmpty)
                          _ContactCard(Icons.chat_outlined, 'WhatsApp', c.whatsapp),
                      ],
                    ),
                  ),
                ),
              ),

            // ─── SOCIAL LINKS ─────────────────
            if (c.behance.isNotEmpty ||
                c.instagram.isNotEmpty ||
                c.youtube.isNotEmpty ||
                c.linkedin.isNotEmpty ||
                c.website.isNotEmpty ||
                c.portfolioOther.isNotEmpty)
              Transform.translate(
                offset: const Offset(0, -32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (c.behance.isNotEmpty) _LinkBtn('Behance'),
                        if (c.instagram.isNotEmpty) _LinkBtn(c.instagram),
                        if (c.youtube.isNotEmpty) _LinkBtn('YouTube'),
                        if (c.linkedin.isNotEmpty) _LinkBtn('LinkedIn'),
                        if (c.website.isNotEmpty) _LinkBtn('Website'),
                        if (c.portfolioOther.isNotEmpty) _LinkBtn('Other'),
                      ],
                    ),
                  ),
                ),
              ),

            // ─── PORTFOLIO GRID ───────────────
            Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Portfolio',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          Text(
                              '${c.portfolio.length} project${c.portfolio.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                  fontSize: 13, color: KeleleColors.grayMid)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(builder: (ctx, constraints) {
                        final cols = constraints.maxWidth > 700
                            ? 3
                            : constraints.maxWidth > 400
                                ? 2
                                : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: c.portfolio.length,
                          itemBuilder: (ctx, i) {
                            final p = c.portfolio[i];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: KeleleColors.grayBorder),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(11)),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            gradient: p.cover),
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Text(
                                                p.title
                                                    .split(' ')
                                                    .map((w) => w.isNotEmpty
                                                        ? w[0]
                                                        : '')
                                                    .join(),
                                                style:
                                                    GoogleFonts.spaceGrotesk(
                                                  fontSize: 48,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              left: 12,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                child: Text(p.skill,
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Colors.white)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.title,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.w600)),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.link,
                                                size: 14,
                                                color: KeleleColors.pink),
                                            const SizedBox(width: 4),
                                            Text(
                                                'View on ${_linkLabel(p.url)}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    color:
                                                        KeleleColors.pink)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _Tag(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
          style:
              TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value, label;
  const _StatCell(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: KeleleColors.grayBorder)),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 1),
            Text(label.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    color: KeleleColors.grayMid,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ContactCard(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: KeleleColors.grayBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: KeleleColors.pink),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      color: KeleleColors.grayMid,
                      letterSpacing: 0.8)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkBtn extends StatelessWidget {
  final String label;
  const _LinkBtn(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: KeleleColors.grayBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link, size: 14, color: KeleleColors.dark),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
