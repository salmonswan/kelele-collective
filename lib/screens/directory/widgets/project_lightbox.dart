import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/creator.dart';
import '../../../providers/creator_provider.dart';
import '../../../theme/app_theme.dart';

class ProjectLightbox extends ConsumerStatefulWidget {
  final int projectId;
  final int creatorId;
  final VoidCallback onClose;
  final void Function(int creatorId) onViewCreator;

  const ProjectLightbox({
    super.key,
    required this.projectId,
    required this.creatorId,
    required this.onClose,
    required this.onViewCreator,
  });

  @override
  ConsumerState<ProjectLightbox> createState() => _ProjectLightboxState();
}

class _ProjectLightboxState extends ConsumerState<ProjectLightbox> {
  bool _showHire = true;

  @override
  Widget build(BuildContext context) {
    final creators = ref.watch(creatorsProvider);
    final bookmarks = ref.watch(bookmarksProvider);
    final c = creators.where((cr) => cr.id == widget.creatorId).firstOrNull;
    if (c == null) return const SizedBox.shrink();
    final p = c.portfolio.where((pi) => pi.id == widget.projectId).firstOrNull;
    if (p == null) return const SizedBox.shrink();
    final bookmarked = bookmarks.contains(c.id);
    final otherProjects = c.portfolio.where((pi) => pi.id != p.id).toList();

    return Material(
      color: Colors.black.withOpacity(0.88),
      child: Column(
        children: [
          // ─── TOP BAR ────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => widget.onViewCreator(c.id),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: KeleleColors.pink,
                        child: Text(c.initials,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          Text('${c.name} · ${p.skill}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _TopAction(
                  bookmarked ? Icons.star : Icons.star_border,
                  bookmarked ? 'Saved' : 'Save',
                  onTap: () => ref.read(bookmarksProvider.notifier).toggle(c.id),
                ),
                const SizedBox(width: 8),
                _TopAction(
                  Icons.link,
                  'Link',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: p.url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied'), duration: Duration(seconds: 2)),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),

          // ─── SCROLLABLE BODY ────────────────
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 900,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 48,
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Column(
                      children: [
                        // Hero
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(gradient: p.cover),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    p.title
                                        .split(' ')
                                        .map((w) => w.isNotEmpty ? w[0] : '')
                                        .join(),
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 96,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  left: 24,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(p.skill,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Details
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title,
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                      letterSpacing: -1)),
                              const SizedBox(height: 24),
                              Text('2025',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              Text(
                                '${c.bio} This project showcases ${c.name.split(' ').first}\'s expertise in ${p.skill.toLowerCase()}.',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: const Color(0xFF555555),
                                    height: 1.8),
                              ),
                              const SizedBox(height: 32),
                              Divider(color: KeleleColors.grayBorder),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 32,
                                runSpacing: 16,
                                children: [
                                  _Meta('Creator', c.name),
                                  _Meta('Discipline', p.skill),
                                  _Meta('Location', c.location),
                                  _Meta('Level', c.levelLabel),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Other project sections
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
                          child: Column(
                            children: otherProjects.map((op) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 10,
                                    child: Container(
                                      decoration:
                                          BoxDecoration(gradient: op.cover),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Text(
                                              op.title
                                                  .split(' ')
                                                  .map((w) => w.isNotEmpty
                                                      ? w[0]
                                                      : '')
                                                  .join(),
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 64,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 24,
                                            left: 24,
                                            child: Text(op.title,
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(
                                                        blurRadius: 8,
                                                        color: Colors.black
                                                            .withOpacity(0.3))
                                                  ],
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── BOTTOM HIRE BAR ────────────────
          if (_showHire)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: KeleleColors.pink,
                    child: Text(c.initials,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${c.name} is available for hire',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      Row(children: [
                        Text('Availability: Now · ',
                            style: TextStyle(
                                fontSize: 12, color: KeleleColors.grayMid)),
                        Text('Responds quickly',
                            style: TextStyle(
                                fontSize: 12,
                                color: KeleleColors.green,
                                fontWeight: FontWeight.w500)),
                      ]),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => widget.onViewCreator(c.id),
                    child: Text('Hire ${c.name.split(' ').first}'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _showHire = false),
                    icon: Icon(Icons.close,
                        size: 18, color: KeleleColors.grayMid),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TopAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _TopAction(this.icon, this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final String label, value;
  const _Meta(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: KeleleColors.grayMid)),
        const SizedBox(height: 2),
        Text(value,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
