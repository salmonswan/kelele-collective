import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/creator.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/status_badge.dart';

class ProfilePanel extends StatelessWidget {
  final Creator creator;
  final VoidCallback onClose;
  final VoidCallback onViewFull;

  const ProfilePanel({
    super.key,
    required this.creator,
    required this.onClose,
    required this.onViewFull,
  });

  @override
  Widget build(BuildContext context) {
    final c = creator;

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: onClose,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        // Drawer
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: MediaQuery.of(context).size.width > 500 ? 420 : MediaQuery.of(context).size.width * 0.9,
          child: Material(
            elevation: 16,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: KeleleColors.grayLight,
                        ),
                      ),
                    ),
                  ),

                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: KeleleColors.pink,
                    child: Text(c.initials,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  if (c.status == CreatorStatus.verified)
                    StatusBadge(status: c.status),
                  const SizedBox(height: 10),
                  Text(c.name,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: KeleleColors.grayMid),
                      const SizedBox(width: 4),
                      Text(c.location,
                          style: TextStyle(
                              fontSize: 13, color: KeleleColors.grayMid)),
                      Text(' · ',
                          style: TextStyle(color: KeleleColors.grayMid)),
                      Text('Available for hire',
                          style: TextStyle(
                              fontSize: 13,
                              color: KeleleColors.green,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tags
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      Text(c.primarySkill,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: KeleleColors.pink)),
                      ...c.skills
                          .where((s) => s != c.primarySkill)
                          .map((s) => Text(s,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: KeleleColors.green))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.email_outlined, size: 18),
                            label: const Text('Send Inquiry'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onViewFull,
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: const Text('Full Profile'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _ContactRow(Icons.email_outlined, c.email),
                        const SizedBox(height: 8),
                        _ContactRow(Icons.phone_outlined, c.phone),
                        if (c.whatsapp.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _ContactRow(Icons.chat_outlined, 'WhatsApp: ${c.whatsapp}'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(c.bio,
                        style: TextStyle(
                            fontSize: 13,
                            color: KeleleColors.grayMid,
                            height: 1.7)),
                  ),
                  const SizedBox(height: 16),

                  // Social links
                  if (c.behance.isNotEmpty ||
                      c.instagram.isNotEmpty ||
                      c.youtube.isNotEmpty ||
                      c.linkedin.isNotEmpty ||
                      c.website.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (c.behance.isNotEmpty)
                            _LinkChip('Behance'),
                          if (c.instagram.isNotEmpty)
                            _LinkChip(c.instagram),
                          if (c.youtube.isNotEmpty)
                            _LinkChip('YouTube'),
                          if (c.linkedin.isNotEmpty)
                            _LinkChip('LinkedIn'),
                          if (c.website.isNotEmpty)
                            _LinkChip('Website'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Portfolio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PROJECTS (${c.portfolio.length})',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: KeleleColors.grayMid,
                                letterSpacing: 1)),
                        const SizedBox(height: 12),
                        GridView.builder(
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
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                decoration:
                                    BoxDecoration(gradient: p.cover),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.6)
                                        ],
                                      ),
                                    ),
                                    child: Text(p.title,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _ContactRow(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: KeleleColors.grayLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: KeleleColors.pink),
          const SizedBox(width: 10),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  final String label;
  const _LinkChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: KeleleColors.grayLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link, size: 14, color: KeleleColors.dark),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
