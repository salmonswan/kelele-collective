import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/creator.dart';
import '../../../theme/app_theme.dart';

final _defaultCovers = [
  const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
  const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
  const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
];

/// Builds an image widget that handles both asset and network paths.
Widget _buildCoverImage(String url, {BoxFit fit = BoxFit.cover, Widget? fallback}) {
  if (url.startsWith('assets/')) {
    return Image.asset(url, fit: fit, errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink());
  }
  return Image.network(url, fit: fit, errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink());
}

class PeopleCard extends StatefulWidget {
  final Creator creator;
  final VoidCallback onTap;
  const PeopleCard({super.key, required this.creator, required this.onTap});

  @override
  State<PeopleCard> createState() => _PeopleCardState();
}

class _PeopleCardState extends State<PeopleCard> {
  bool _hovered = false;

  /// Returns a widget showing the portfolio cover image or gradient fallback.
  Widget _coverTile(int index) {
    final c = widget.creator;
    if (index < c.portfolio.length && c.portfolio[index].hasCoverImage) {
      final p = c.portfolio[index];
      return _buildCoverImage(
        p.coverImageUrl,
        fallback: Container(decoration: BoxDecoration(gradient: p.cover)),
      );
    }
    // Gradient fallback
    final gradient = index < c.portfolio.length
        ? c.portfolio[index].cover
        : _defaultCovers[index % _defaultCovers.length];
    return Container(decoration: BoxDecoration(gradient: gradient));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.creator;
    final isAssetPhoto = c.profilePhotoUrl.startsWith('assets/');

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? KeleleColors.pinkLight : KeleleColors.grayBorder,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))]
                : [],
          ),
          child: Column(
            children: [
              // ─── IMAGE COLLAGE ───────────────────
              Expanded(
                child: Column(
                  children: [
                    // Main image (top, ~60%)
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        width: double.infinity,
                        child: _coverTile(0),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Two smaller images side by side (~25%)
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(child: _coverTile(1)),
                          const SizedBox(width: 2),
                          Expanded(child: _coverTile(2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── PROFILE CIRCLE + TEXT ──────────────
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Text area
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 28, 12, 12),
                    child: Column(
                      children: [
                        Text(
                          c.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                c.mainSkill.discipline,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: KeleleColors.pink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.circle, size: 3, color: KeleleColors.grayMid),
                            ),
                            Icon(Icons.location_on, size: 11, color: KeleleColors.grayMid),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                c.location,
                                style: TextStyle(fontSize: 13, color: KeleleColors.grayMid),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (c.status == CreatorStatus.verifiedEmerging)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: KeleleColors.orangeGlow,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Text(
                                'Emerging',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: KeleleColors.orange,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Profile photo circle — always shows image
                  Positioned(
                    top: -24,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: KeleleColors.grayLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: isAssetPhoto
                          ? Image.asset(c.profilePhotoUrl, fit: BoxFit.cover)
                          : Image.network(c.profilePhotoUrl, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
