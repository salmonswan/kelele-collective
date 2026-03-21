import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/creator.dart';
import '../../../theme/app_theme.dart';

class ProjectCard extends StatefulWidget {
  final PortfolioItem project;
  final Creator creator;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.creator,
    required this.onTap,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: _hovered
              ? (Matrix4.identity()..translateByDouble(0.0, -4.0, 0.0, 0.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: _hovered
                ? [BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 32, offset: const Offset(0, 12))]
                : [BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: widget.project.cover,
                      image: widget.project.hasCoverImage
                          ? DecorationImage(
                              image: NetworkImage(widget.project.coverImageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            widget.creator.initials,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha:0.12),
                            ),
                          ),
                        ),
                        // Skill overlay on hover
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _hovered ? 1 : 0,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withValues(alpha:0.5)],
                                ),
                              ),
                              child: Text(
                                widget.project.skill,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Info
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: KeleleColors.pink,
                            child: Text(
                              widget.creator.initials,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.creator.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: KeleleColors.grayMid,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
