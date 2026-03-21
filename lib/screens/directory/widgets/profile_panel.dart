import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/mock_data.dart';
import '../../../models/creator.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/status_badge.dart';

class ProfilePanel extends StatefulWidget {
  final Creator creator;
  final VoidCallback onClose;
  final VoidCallback onViewFull;
  final void Function(String projectId, String creatorId)? onOpenProject;
  final bool isGuest;
  final VoidCallback? onSignUpPrompt;

  const ProfilePanel({
    super.key,
    required this.creator,
    required this.onClose,
    required this.onViewFull,
    this.onOpenProject,
    this.isGuest = false,
    this.onSignUpPrompt,
  });

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _scale = Tween(begin: 0.95, end: 1.0)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.creator;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final modalW = screenW > 700 ? 620.0 : screenW * 0.94;
    final modalH = screenH * 0.9;

    final coverGrad = c.portfolio.isNotEmpty
        ? c.portfolio.first.cover
        : const LinearGradient(
            colors: [KeleleColors.dark, KeleleColors.darkSoft]);
    final coverImage =
        c.portfolio.isNotEmpty && c.portfolio.first.hasCoverImage
            ? c.portfolio.first.coverImageUrl
            : null;

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: widget.onClose,
          child: FadeTransition(
            opacity: _fade,
            child:
                Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        // Centered modal
        Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                width: modalW,
                constraints: BoxConstraints(maxHeight: modalH),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── COVER + PHOTO + CLOSE ─────────
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Cover
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(gradient: coverGrad),
                          child: coverImage != null
                              ? (coverImage.startsWith('assets/')
                                  ? Image.asset(coverImage,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox.shrink())
                                  : Image.network(coverImage,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox.shrink()))
                              : const SizedBox.shrink(),
                        ),
                        // Back + Close buttons
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _PanelIconBtn(
                            icon: Icons.arrow_back,
                            onTap: widget.onClose,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _PanelIconBtn(
                            icon: Icons.close,
                            onTap: widget.onClose,
                          ),
                        ),
                        // Profile photo — bottom right
                        Positioned(
                          bottom: -36,
                          right: 20,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: KeleleColors.grayLight,
                              border: Border.all(
                                  color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: c.profilePhotoUrl.isNotEmpty
                                ? (c.profilePhotoUrl
                                        .startsWith('assets/')
                                    ? Image.asset(c.profilePhotoUrl,
                                        fit: BoxFit.cover)
                                    : Image.network(c.profilePhotoUrl,
                                        fit: BoxFit.cover))
                                : Center(
                                    child: Text(c.initials,
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: KeleleColors.pink)),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    // Space for profile photo overflow
                    const SizedBox(height: 40),

                    // ─── NAME & INFO ─────────────────
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text(
                            c.companyRole != CompanyRole.none &&
                                    c.companyName.isNotEmpty
                                ? '${_companyRoleLabel(c.companyRole)} at ${c.companyName}, ${c.location}'
                                : c.location,
                            style: TextStyle(
                                fontSize: 14,
                                color: KeleleColors.grayMid),
                          ),
                          if (c.artistName != null &&
                              c.artistName!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text('aka ${c.artistName}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: KeleleColors.grayMid,
                                    fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                    ),

                    // ─── SKILLS + VERIFIED BADGE ─────
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 5,
                              runSpacing: 5,
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
                                ...c.sideSkills
                                    .map((s) => _SkillChip(
                                          discipline: s.discipline,
                                          specification:
                                              s.specification,
                                          years:
                                              s.yearsOfExperience,
                                          isMain: false,
                                        )),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: StatusBadge(status: c.status),
                          ),
                        ],
                      ),
                    ),

                    // ─── SHOWREEL ─────────────────────
                    if (c.featuredVideoUrls.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: GestureDetector(
                          onTap: () => launchUrl(
                              Uri.parse(c.featuredVideoUrls.first)),
                          child: Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  KeleleColors.pink,
                                  KeleleColors.pinkDark
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white
                                              .withValues(
                                                  alpha: 0.4),
                                          width: 2),
                                    ),
                                    child: const Icon(
                                        Icons.play_arrow,
                                        size: 32,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                      c.featuredVideoUrls.length > 1
                                          ? 'Showreel (+${c.featuredVideoUrls.length - 1} more)'
                                          : 'Showreel (embedded)',
                                      style: TextStyle(
                                          color: Colors.white
                                              .withValues(
                                                  alpha: 0.9),
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ─── BIO + ACTIONS ────────────────
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Text(c.bio,
                          style: TextStyle(
                              fontSize: 13,
                              color: KeleleColors.grayMid,
                              height: 1.6)),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: widget.isGuest
                                ? ElevatedButton.icon(
                                    onPressed: widget.onSignUpPrompt,
                                    icon: const Icon(
                                        Icons.person_add_outlined,
                                        size: 18),
                                    label: const Text(
                                        'Sign up to connect'),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () => launchUrl(
                                      Uri.parse(
                                          'mailto:${c.email}?subject=Let\'s collaborate! (via Kelele)'),
                                    ),
                                    icon: const Icon(
                                        Icons.email_outlined,
                                        size: 18),
                                    label:
                                        const Text('Get in touch'),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: widget.onViewFull,
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share'),
                          ),
                        ],
                      ),
                    ),

                    // ─── INDUSTRY & TOOLS ─────────────
                    if (c.specialties.isNotEmpty ||
                        c.software.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (c.specialties.isNotEmpty)
                              Expanded(
                                child: _MiniSection(
                                  title: 'I work in',
                                  children: c.specialties
                                      .take(4)
                                      .map((s) =>
                                          specialtyLabels[s] ??
                                          s.name)
                                      .toList(),
                                ),
                              ),
                            if (c.specialties.isNotEmpty &&
                                c.software.isNotEmpty)
                              const SizedBox(width: 10),
                            if (c.software.isNotEmpty)
                              Expanded(
                                child: _MiniSection(
                                  title: 'My toolkit',
                                  children:
                                      c.software.take(5).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // ─── SERVICES ─────────────────────
                    if (c.services.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: _MiniSection(
                          title: 'How I can help',
                          body: c.services,
                        ),
                      ),

                    // ─── PORTFOLIO ────────────────────
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text('Portfolio',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 10, 20, 32),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 4 / 3,
                        ),
                        itemCount: c.portfolio.length,
                        itemBuilder: (ctx, i) {
                          final p = c.portfolio[i];
                          return GestureDetector(
                            onTap: widget.onOpenProject != null
                                ? () => widget.onOpenProject!(
                                    p.id, c.id)
                                : null,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: p.cover,
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (p.hasCoverImage)
                                      p.coverImageUrl
                                              .startsWith('assets/')
                                          ? Image.asset(
                                              p.coverImageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                      const SizedBox
                                                          .shrink())
                                          : Image.network(
                                              p.coverImageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                      const SizedBox
                                                          .shrink()),
                                    Align(
                                      alignment:
                                          Alignment.bottomLeft,
                                      child: Container(
                                        width: double.infinity,
                                        padding:
                                            const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin:
                                                Alignment.topCenter,
                                            end: Alignment
                                                .bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black
                                                  .withValues(
                                                      alpha: 0.6),
                                            ],
                                          ),
                                        ),
                                        child: Text(p.title,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color:
                                                    Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      ],
    );
  }
}

// ─── MINI SECTION (card for specialties/tools/services) ───
class _MiniSection extends StatelessWidget {
  final String title;
  final List<String>? children;
  final String? body;

  const _MiniSection({required this.title, this.children, this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KeleleColors.grayLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: KeleleColors.grayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
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
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(label,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

// ─── PANEL ICON BUTTON ───────────────────────
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

// ─── SKILL CHIP ──────────────────────────────
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
      padding: EdgeInsets.symmetric(
        horizontal: isMain ? 10 : 8,
        vertical: isMain ? 7 : 5,
      ),
      decoration: BoxDecoration(
        color: isMain ? KeleleColors.pinkGlow : KeleleColors.grayLight,
        borderRadius: BorderRadius.circular(100),
        border:
            isMain ? Border.all(color: KeleleColors.pink, width: 1.5) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$discipline${specification != null ? " for $specification" : ""}',
            style: TextStyle(
              fontSize: isMain ? 13 : 12,
              fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
              color: isMain ? KeleleColors.pinkDark : KeleleColors.dark,
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isMain ? KeleleColors.pink : KeleleColors.dark,
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

String _companyRoleLabel(CompanyRole role) {
  switch (role) {
    case CompanyRole.founder:
      return 'Founder';
    case CompanyRole.coFounder:
      return 'Co-Founder';
    case CompanyRole.employee:
      return 'Employee';
    case CompanyRole.none:
      return '';
  }
}
