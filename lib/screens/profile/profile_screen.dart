import 'dart:async';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config.dart';
import '../../data/mock_data.dart';
import '../../models/creator.dart';
import '../../providers/creator_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════
//  PROFILE SCREEN (modal overlay)
// ═══════════════════════════════════════════════════════

class ProfileScreen extends ConsumerStatefulWidget {
  final String creatorId;
  const ProfileScreen({super.key, required this.creatorId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int? _galleryIndex;

  void _openGallery(int index) => setState(() => _galleryIndex = index);
  void _closeGallery() => setState(() => _galleryIndex = null);

  @override
  Widget build(BuildContext context) {
    final creators = ref.watch(creatorsProvider);
    final user = ref.watch(currentUserProvider);
    final bookmarks = ref.watch(bookmarksProvider);
    final c = creators.where((cr) => cr.id == widget.creatorId).firstOrNull;

    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final isMobile = screenW < 600;
    final modalW = isMobile ? screenW : screenW * 0.70;
    final hPad = isMobile ? 16.0 : 24.0;

    if (c == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
            Center(
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
            ),
          ],
        ),
      );
    }

    final bookmarked = bookmarks.contains(c.id);
    final isGuest = user?.isGuest == true;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ─── DARK BACKDROP ──────────────────
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),

          // ─── MODAL ─────────────────────────
          Center(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) {},
              child: Container(
                width: modalW,
                height: screenH,
                decoration: BoxDecoration(
                  color: KeleleColors.grayLight,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // ─── SCROLLABLE CONTENT ───────
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── COVER SLIDESHOW ──────────────
                          _CoverSlideshow(
                            portfolio: c.portfolio,
                            height: isMobile ? 320.0 : 480.0,
                          ),

                          // ─── PROFILE INFO (photo + name + skills + bio) ──
                          Padding(
                            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ProfilePhoto(creator: c, size: 128),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(c.name,
                                                style:
                                                    GoogleFonts.spaceGrotesk(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                          ),
                                          if (c.companyName.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Text(c.companyName,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: KeleleColors
                                                        .grayMid)),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Skills — uniform style
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          _SkillChip(
                                            discipline:
                                                c.mainSkill.discipline,
                                            specification:
                                                c.mainSkill.specification,
                                            years: c.mainSkill
                                                .yearsOfExperience,
                                            isMain: true,
                                          ),
                                          ...c.sideSkills.map(
                                              (s) => _SkillChip(
                                                    discipline:
                                                        s.discipline,
                                                    specification:
                                                        s.specification,
                                                    years:
                                                        s.yearsOfExperience,
                                                  )),
                                        ],
                                      ),
                                      // Bio — right of photo, below skills
                                      if (c.bio.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        Text(c.bio,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: KeleleColors.grayMid,
                                                height: 1.6)),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ─── TWO-COLUMN INFO ──────────────
                          Padding(
                            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
                            child: isMobile
                                ? Column(
                                    children: [
                                      _LinkUpCard(
                                        creator: c,
                                        isGuest: isGuest,
                                        user: user,
                                        ref: ref,
                                        context: context,
                                      ),
                                      if (c.clients.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        _ClientsCard(creator: c),
                                      ],
                                      const SizedBox(height: 12),
                                      _InfoColumn(creator: c),
                                    ],
                                  )
                                : IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: _LinkUpCard(
                                                  creator: c,
                                                  isGuest: isGuest,
                                                  user: user,
                                                  ref: ref,
                                                  context: context,
                                                ),
                                              ),
                                              if (c.clients.isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                _ClientsCard(creator: c),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _InfoColumn(creator: c),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),

                          // ─── GALLERY ──────────────────────
                          if (c.portfolio.isNotEmpty ||
                              c.featuredVideoUrls.isNotEmpty)
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(hPad, 24, hPad, 32),
                              child: _PortfolioGallery(
                                creator: c,
                                isMobile: isMobile,
                                onTapImage: _openGallery,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ─── TOP BAR ─────────────────────
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            // X + Back
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _PanelIconBtn(
                                    icon: Icons.close,
                                    onTap: () => context.pop(),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Back',
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Bookmark
                            if (!isGuest)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _PanelIconBtn(
                                  icon: bookmarked
                                      ? Icons.star
                                      : Icons.star_border,
                                  onTap: () => toggleBookmark(ref, c.id).catchError((_) {}),
                                ),
                              ),
                            // Share
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                  text:
                                      '${Uri.base.origin}/profile/${c.id}',
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Profile link copied'),
                                      duration: Duration(seconds: 2)),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.share,
                                        size: 14, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text('Share',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── GALLERY LIGHTBOX OVERLAY ─────
          if (_galleryIndex != null)
            _GalleryLightbox(
              items: c.portfolio,
              initialIndex: _galleryIndex!,
              onClose: _closeGallery,
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COVER SLIDESHOW
// ═══════════════════════════════════════════════════════

class _CoverSlideshow extends StatefulWidget {
  final List<PortfolioItem> portfolio;
  final double height;

  const _CoverSlideshow({required this.portfolio, required this.height});

  @override
  State<_CoverSlideshow> createState() => _CoverSlideshowState();
}

class _CoverSlideshowState extends State<_CoverSlideshow> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.portfolio.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.portfolio.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildImage(PortfolioItem item) {
    return Container(
      key: ValueKey(item.id),
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(gradient: item.cover),
      child: item.hasCoverImage
          ? (item.isAssetImage
              ? Image.asset(item.coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink())
              : Image.network(item.coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.portfolio.isEmpty) {
      return Container(
        width: double.infinity,
        height: widget.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [KeleleColors.dark, KeleleColors.darkSoft]),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _buildImage(widget.portfolio[_currentIndex]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PROFILE PHOTO
// ═══════════════════════════════════════════════════════

class _ProfilePhoto extends StatelessWidget {
  final Creator creator;
  final double size;
  const _ProfilePhoto({required this.creator, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: KeleleColors.grayLight,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: creator.profilePhotoUrl.isNotEmpty
          ? (creator.profilePhotoUrl.startsWith('assets/')
              ? Image.asset(creator.profilePhotoUrl, fit: BoxFit.cover)
              : Image.network(creator.profilePhotoUrl, fit: BoxFit.cover))
          : Center(
              child: Text(creator.initials,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: size * 0.32,
                      fontWeight: FontWeight.w700,
                      color: KeleleColors.pink)),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PANEL ICON BUTTON
// ═══════════════════════════════════════════════════════

class _PanelIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PanelIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SKILL CHIP (uniform — no main/side distinction)
// ═══════════════════════════════════════════════════════

class _SkillChip extends StatelessWidget {
  final String discipline;
  final String? specification;
  final int years;
  final bool isMain;
  const _SkillChip({
    required this.discipline,
    this.specification,
    required this.years,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: KeleleColors.grayLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$discipline${specification != null ? " $specification" : ""}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isMain ? FontWeight.w700 : FontWeight.w500,
              color: KeleleColors.dark,
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: KeleleColors.dark,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$years yrs',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  LINK UP CARD (left column)
// ═══════════════════════════════════════════════════════

class _LinkUpCard extends StatelessWidget {
  final Creator creator;
  final bool isGuest;
  final dynamic user;
  final WidgetRef ref;
  final BuildContext context;

  const _LinkUpCard({
    required this.creator,
    required this.isGuest,
    required this.user,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    final firstName = creator.name.split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KeleleColors.grayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Location — in the white card
          Text('Link up with $firstName',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.pin_drop_outlined,
                  size: 16, color: KeleleColors.grayMid),
              const SizedBox(width: 6),
              Text('Based in ${creator.location} Area',
                  style: const TextStyle(
                      fontSize: 14, color: KeleleColors.grayMid)),
            ],
          ),
          const SizedBox(height: 12),

          // Grey inner card — contacts, socials, CTA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KeleleColors.grayLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact items
                if (creator.website.isNotEmpty)
                  _ContactItem(
                    icon: Icons.language,
                    label: 'Website',
                    value: isGuest ? null : creator.website,
                  ),
                if (creator.phone.isNotEmpty)
                  _ContactItem(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: isGuest ? null : creator.phone,
                  ),
                if (creator.whatsapp.isNotEmpty)
                  _ContactItem(
                    icon: Icons.chat_outlined,
                    label: 'Whatsapp',
                    value: isGuest ? null : creator.whatsapp,
                  ),

                // Social icons
                if (_hasSocials) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (creator.behance.isNotEmpty)
                        _SocialIcon(label: 'Be', url: creator.behance),
                      if (creator.instagram.isNotEmpty)
                        _SocialIcon(label: 'Ig', url: creator.instagram),
                      if (creator.youtube.isNotEmpty)
                        _SocialIcon(label: 'Yt', url: creator.youtube),
                      if (creator.linkedin.isNotEmpty)
                        _SocialIcon(label: 'Li', url: creator.linkedin),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // CTA button
                Row(
                  children: [
                    Expanded(
                      child: isGuest
                          ? ElevatedButton.icon(
                              onPressed: () async {
                                ref.read(isGuestProvider.notifier).state = false;
                                if (useMockData) {
                                  ref
                                      .read(mockAuthProvider.notifier)
                                      .logout();
                                } else {
                                  await ref
                                      .read(authServiceProvider)
                                      .signOut();
                                }
                              },
                              icon: const Icon(
                                  Icons.person_add_outlined,
                                  size: 16),
                              label:
                                  const Text('Sign up to connect'),
                            )
                          : ElevatedButton.icon(
                              onPressed: () => launchUrl(Uri.parse(
                                  'mailto:${creator.email}?subject=Let\'s collaborate! (via Kelele)')),
                              icon: const Icon(
                                  Icons.email_outlined,
                                  size: 16),
                              label: const Text('Get in touch'),
                            ),
                    ),
                    if (isGuest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: KeleleColors.grayBorder,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.lock_outline,
                            size: 16, color: KeleleColors.grayMid),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  bool get _hasSocials =>
      creator.behance.isNotEmpty ||
      creator.instagram.isNotEmpty ||
      creator.youtube.isNotEmpty ||
      creator.linkedin.isNotEmpty;
}

// ─── Clients card ────────────────────────────────
class _ClientsCard extends StatelessWidget {
  final Creator creator;
  const _ClientsCard({required this.creator});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KeleleColors.grayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clients I\'ve worked for',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            creator.clients.join(', '),
            style: const TextStyle(
                fontSize: 13,
                color: KeleleColors.grayMid,
                height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ─── Contact item row ────────────────────────────
class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const _ContactItem(
      {required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: KeleleColors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 14, color: KeleleColors.dark)),
          if (value != null) ...[
            const SizedBox(width: 4),
            Flexible(
              child: Text(value!,
                  style: const TextStyle(
                      fontSize: 13, color: KeleleColors.grayMid),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Social icon circle ──────────────────────────
class _SocialIcon extends StatelessWidget {
  final String label;
  final String url;
  const _SocialIcon({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final uri = url.startsWith('http') ? url : 'https://$url';
        launchUrl(Uri.parse(uri));
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: KeleleColors.dark,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  INFO COLUMN (right column — specialties, toolkit, services)
// ═══════════════════════════════════════════════════════

class _InfoColumn extends StatelessWidget {
  final Creator creator;
  const _InfoColumn({required this.creator});

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];
    if (creator.specialties.isNotEmpty) {
      sections.add(_MiniSection(
        title: 'Specialises in',
        children: creator.specialties
            .take(5)
            .map((s) => specialtyLabels[s] ?? s.name)
            .toList(),
      ));
    }
    if (creator.software.isNotEmpty) {
      sections.add(_MiniSection(
        title: 'Toolkit',
        children: creator.software.take(5).toList(),
      ));
    }
    if (creator.services.isNotEmpty) {
      sections.add(_MiniSection(
        title: 'Services',
        body: creator.services,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Expanded(child: sections[i]),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  MINI SECTION (industry/tools/services cards)
// ═══════════════════════════════════════════════════════

class _MiniSection extends StatelessWidget {
  final String title;
  final List<String>? children;
  final String? body;
  const _MiniSection({required this.title, this.children, this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KeleleColors.grayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (body != null)
            Text(body!,
                style: const TextStyle(
                    fontSize: 14, height: 1.4, color: KeleleColors.dark)),
          if (children != null)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: children!
                  .map((label) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: KeleleColors.grayLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(label,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PORTFOLIO GALLERY
// ═══════════════════════════════════════════════════════

class _PortfolioGallery extends StatelessWidget {
  final Creator creator;
  final bool isMobile;
  final void Function(int index) onTapImage;

  const _PortfolioGallery({
    required this.creator,
    required this.isMobile,
    required this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasShowreel = creator.featuredVideoUrls.isNotEmpty;
    const gap = 6.0;
    final cols = isMobile ? 2 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Text('Gallery',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Text(
              '${creator.portfolio.length} item${creator.portfolio.length != 1 ? 's' : ''}',
              style: const TextStyle(
                  fontSize: 13, color: KeleleColors.grayMid),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Single collage box
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: KeleleColors.grayLight,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(gap),
          child: Column(
            children: [
              // Showreel hero row (if present)
              if (hasShowreel) ...[
                isMobile
                    // Mobile: showreel full width
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _ShowreelEmbed(
                          url: creator.featuredVideoUrls.first,
                          aspectRatio: 16 / 9,
                        ),
                      )
                    // Desktop: showreel 2/3 + first two images stacked 1/3
                    : IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _ShowreelEmbed(
                                  url: creator.featuredVideoUrls.first,
                                  aspectRatio: 16 / 9,
                                ),
                              ),
                            ),
                            if (creator.portfolio.isNotEmpty) ...[
                              const SizedBox(width: gap),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: _GalleryTile(
                                        item: creator.portfolio[0],
                                        onTap: () => onTapImage(0),
                                      ),
                                    ),
                                    if (creator.portfolio.length > 1) ...[
                                      const SizedBox(height: gap),
                                      Expanded(
                                        child: _GalleryTile(
                                          item: creator.portfolio[1],
                                          onTap: () => onTapImage(1),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                if (_gridItems(hasShowreel).isNotEmpty)
                  const SizedBox(height: gap),
              ],

              // Remaining images in a uniform grid
              if (_gridItems(hasShowreel).isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: gap,
                    mainAxisSpacing: gap,
                    childAspectRatio: 4 / 3,
                  ),
                  itemCount: _gridItems(hasShowreel).length,
                  itemBuilder: (_, i) {
                    final actualIndex = _gridStartIndex(hasShowreel) + i;
                    return _GalleryTile(
                      item: _gridItems(hasShowreel)[i],
                      onTap: () => onTapImage(actualIndex),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  // On desktop with showreel, first 2 images are beside the showreel
  int _gridStartIndex(bool hasShowreel) {
    if (!hasShowreel) return 0;
    return isMobile ? 0 : 2.clamp(0, creator.portfolio.length);
  }

  List<PortfolioItem> _gridItems(bool hasShowreel) {
    final start = _gridStartIndex(hasShowreel);
    if (start >= creator.portfolio.length) return [];
    return creator.portfolio.sublist(start);
  }
}

// ─── Gallery tile ────────────────────────────────
class _GalleryTile extends StatelessWidget {
  final PortfolioItem item;
  final VoidCallback onTap;

  const _GalleryTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: item.cover,
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.hasCoverImage)
              item.isAssetImage
                  ? Image.asset(item.coverImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const SizedBox.shrink())
                  : Image.network(item.coverImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const SizedBox.shrink()),
            // Bottom label
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Text(item.title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SHOWREEL EMBED (iframe for YouTube/Vimeo)
// ═══════════════════════════════════════════════════════

class _ShowreelEmbed extends StatefulWidget {
  final String url;
  final double aspectRatio;

  const _ShowreelEmbed({required this.url, required this.aspectRatio});

  @override
  State<_ShowreelEmbed> createState() => _ShowreelEmbedState();
}

class _ShowreelEmbedState extends State<_ShowreelEmbed> {
  late final String _viewType;

  String _toEmbedUrl(String url) {
    // YouTube: convert watch URL to embed
    final ytMatch = RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]+)')
        .firstMatch(url);
    if (ytMatch != null) return 'https://www.youtube.com/embed/${ytMatch.group(1)}';
    // YouTube short URL
    final ytShort =
        RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)').firstMatch(url);
    if (ytShort != null) return 'https://www.youtube.com/embed/${ytShort.group(1)}';
    // YouTube already embed
    if (url.contains('youtube.com/embed/')) return url;
    // Vimeo
    final vimeoMatch =
        RegExp(r'vimeo\.com/(\d+)').firstMatch(url);
    if (vimeoMatch != null) return 'https://player.vimeo.com/video/${vimeoMatch.group(1)}';
    // Vimeo example URLs (mock data)
    if (url.contains('vimeo.com/example/')) {
      return url; // Fallback — won't embed but won't crash
    }
    return url;
  }

  @override
  void initState() {
    super.initState();
    _viewType = 'showreel-${widget.url.hashCode}';
    final embedUrl = _toEmbedUrl(widget.url);

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = embedUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.borderRadius = '10px'
        ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  GALLERY LIGHTBOX (Apple-style fullscreen overlay)
// ═══════════════════════════════════════════════════════

class _GalleryLightbox extends StatefulWidget {
  final List<PortfolioItem> items;
  final int initialIndex;
  final VoidCallback onClose;

  const _GalleryLightbox({
    required this.items,
    required this.initialIndex,
    required this.onClose,
  });

  @override
  State<_GalleryLightbox> createState() => _GalleryLightboxState();
}

class _GalleryLightboxState extends State<_GalleryLightbox> {
  late int _currentIndex;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < widget.items.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  Widget _buildCurrentImage() {
    final item = widget.items[_currentIndex];
    return Container(
      key: ValueKey(item.id),
      decoration: BoxDecoration(
        gradient: item.cover,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: item.hasCoverImage
          ? (item.isAssetImage
              ? Image.asset(item.coverImageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink())
              : Image.network(item.coverImageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()))
          : Center(
              child: Text(item.title,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_currentIndex];
    final screenW = MediaQuery.of(context).size.width;
    final isMobile = screenW < 600;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) _next();
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _prev();
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onClose();
          }
        }
      },
      child: GestureDetector(
        // Swipe on mobile
        onHorizontalDragEnd: isMobile
            ? (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < -200) _next();
                  if (details.primaryVelocity! > 200) _prev();
                }
              }
            : null,
        child: Stack(
          children: [
            // Dark backdrop
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                  color: Colors.black.withValues(alpha: 0.92)),
            ),

            // Centered image
            Positioned.fill(
              top: 60,
              bottom: 100,
              left: isMobile ? 16 : 60,
              right: isMobile ? 16 : 60,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentImage(),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 20, color: Colors.white),
                ),
              ),
            ),

            // Left arrow
            if (_currentIndex > 0)
              Positioned(
                left: isMobile ? 4 : 16,
                top: 0,
                bottom: 100,
                child: Center(
                  child: GestureDetector(
                    onTap: _prev,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left,
                          size: 28, color: Colors.white),
                    ),
                  ),
                ),
              ),

            // Right arrow
            if (_currentIndex < widget.items.length - 1)
              Positioned(
                right: isMobile ? 4 : 16,
                top: 0,
                bottom: 100,
                child: Center(
                  child: GestureDetector(
                    onTap: _next,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right,
                          size: 28, color: Colors.white),
                    ),
                  ),
                ),
              ),

            // Bottom bar: title + thumbnail strip
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Title
                    Text(item.title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(item.skill,
                        style: TextStyle(
                            fontSize: 13,
                            color:
                                Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 12),
                    // Thumbnail strip
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 6),
                        itemBuilder: (_, i) {
                          final thumb = widget.items[i];
                          final isActive = i == _currentIndex;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _currentIndex = i),
                            child: Container(
                              width: 60,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: thumb.cover,
                                borderRadius:
                                    BorderRadius.circular(4),
                                border: isActive
                                    ? Border.all(
                                        color: KeleleColors.pink,
                                        width: 2)
                                    : null,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: thumb.hasCoverImage
                                  ? (thumb.isAssetImage
                                      ? Image.asset(
                                          thumb.coverImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) =>
                                                  const SizedBox
                                                      .shrink())
                                      : Image.network(
                                          thumb.coverImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) =>
                                                  const SizedBox
                                                      .shrink()))
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

