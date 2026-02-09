import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/creator.dart';
import '../../../theme/app_theme.dart';

final _defaultCovers = [
  const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
  const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
  const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
  const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)]),
];

class PeopleCard extends StatefulWidget {
  final Creator creator;
  final VoidCallback onTap;
  const PeopleCard({super.key, required this.creator, required this.onTap});

  @override
  State<PeopleCard> createState() => _PeopleCardState();
}

class _PeopleCardState extends State<PeopleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.creator;
    // Build thumbnail covers (fill to 4)
    final covers = <LinearGradient>[];
    for (var i = 0; i < 4; i++) {
      if (i < c.portfolio.length) {
        covers.add(c.portfolio[i].cover);
      } else {
        covers.add(_defaultCovers[i % 4]);
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? KeleleColors.pinkLight : KeleleColors.grayBorder,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8))]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thumbnail strip
              SizedBox(
                height: 56,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(11)),
                  child: Row(
                    children: covers
                        .map((g) => Expanded(
                            child: Container(decoration: BoxDecoration(gradient: g))))
                        .toList(),
                  ),
                ),
              ),

              // Avatar
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: KeleleColors.pink,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Center(
                    child: Text(c.initials,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ),
                ),
              ),

              // Body (pull up to close gap)
              Transform.translate(
                offset: const Offset(0, -18),
                child: Column(
                  children: [
                    // Name
                    Text(c.name,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    // Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on,
                            size: 12, color: KeleleColors.grayMid),
                        const SizedBox(width: 3),
                        Text(c.location,
                            style: TextStyle(
                                fontSize: 12, color: KeleleColors.grayMid)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Tags
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      children: [
                        Text(c.primarySkill,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: KeleleColors.pink)),
                        ...c.skills
                            .where((s) => s != c.primarySkill)
                            .map((s) => Text(s,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: KeleleColors.green))),
                        Text(c.priceLabel,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: KeleleColors.purple)),
                      ],
                    ),
                    if (c.featured) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: KeleleColors.greenGlow,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 12, color: KeleleColors.green),
                            const SizedBox(width: 4),
                            Text('Featured',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: KeleleColors.green)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    // Stats
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border(top: BorderSide(color: KeleleColors.grayBorder)),
                      ),
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          _Stat('${c.portfolio.length}', 'Projects'),
                          _Stat('${c.skills.length}', 'Skills'),
                          _Stat(c.levelLabel, 'Level'),
                        ],
                      ),
                    ),
                    // Action button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: widget.onTap,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          child: Text('View ${c.name.split(' ').first}'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: KeleleColors.grayBorder.withOpacity(0.5))),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 1),
            Text(label.toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    color: KeleleColors.grayMid,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
