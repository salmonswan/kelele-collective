import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/creator.dart';
import '../../providers/creator_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  String _filter = 'all';
  int? _reviewingId;
  final _notesC = TextEditingController();
  bool _showNotYetTemplate = false;
  String _notYetName = '';
  String _notYetNotes = '';

  @override
  void dispose() {
    _notesC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creators = ref.watch(creatorsProvider);
    final verified = creators.where((c) => c.status == CreatorStatus.verified).length;
    final pending = creators.where((c) => c.status == CreatorStatus.pending).length;
    final notYet = creators.where((c) => c.status == CreatorStatus.notYet).length;

    final filtered = _filter == 'all'
        ? creators
        : _filter == 'pending'
            ? creators.where((c) => c.status == CreatorStatus.pending).toList()
            : _filter == 'verified'
                ? creators.where((c) => c.status == CreatorStatus.verified).toList()
                : creators.where((c) => c.status == CreatorStatus.notYet).toList();

    final reviewing =
        _reviewingId != null ? creators.where((c) => c.id == _reviewingId).firstOrNull : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Panel',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Manage creator applications and vetting',
                style: TextStyle(fontSize: 14, color: KeleleColors.grayMid)),
            const SizedBox(height: 24),

            // Stats row
            Row(
              children: [
                _StatCard('Verified', '$verified', KeleleColors.green, KeleleColors.greenGlow),
                const SizedBox(width: 12),
                _StatCard('Pending', '$pending', KeleleColors.orange, KeleleColors.orangeGlow),
                const SizedBox(width: 12),
                _StatCard('Rejected', '$notYet', KeleleColors.red, KeleleColors.redGlow),
                const SizedBox(width: 12),
                _StatCard('Total', '${creators.length}', KeleleColors.dark, KeleleColors.grayLight),
              ],
            ),
            const SizedBox(height: 28),

            // Filter chips
            Wrap(
              spacing: 8,
              children: [
                _FilterChip('All', 'all', _filter, (v) => setState(() => _filter = v)),
                _FilterChip('Pending', 'pending', _filter, (v) => setState(() => _filter = v)),
                _FilterChip('Verified', 'verified', _filter, (v) => setState(() => _filter = v)),
                _FilterChip('Rejected', 'not_yet', _filter, (v) => setState(() => _filter = v)),
              ],
            ),
            const SizedBox(height: 20),

            // Creator list
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: KeleleColors.grayBorder),
              ),
              child: Column(
                children: filtered.map((c) {
                  final isReviewing = _reviewingId == c.id;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() =>
                            _reviewingId = isReviewing ? null : c.id),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: KeleleColors.pink,
                                child: Text(c.initials,
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        '${c.primarySkill} · ${c.location}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: KeleleColors.grayMid)),
                                  ],
                                ),
                              ),
                              StatusBadge(status: c.status),
                              const SizedBox(width: 8),
                              Icon(
                                isReviewing
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: KeleleColors.grayMid,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expanded review panel
                      if (isReviewing && reviewing != null)
                        Container(
                          color: KeleleColors.grayLight,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Review ${reviewing.name}',
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  const Spacer(),
                                  if (reviewing.companyName.isNotEmpty)
                                    Text(reviewing.companyName,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: KeleleColors.grayMid)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('${reviewing.email} · ${reviewing.phone}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: KeleleColors.grayMid)),
                                  if (reviewing.whatsapp.isNotEmpty) ...[
                                    Text(' · WA: ${reviewing.whatsapp}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: KeleleColors.green)),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: reviewing.skills
                                    .map((s) => Chip(
                                          label: Text(s),
                                          padding: EdgeInsets.zero,
                                          labelStyle:
                                              const TextStyle(fontSize: 12),
                                          visualDensity: VisualDensity.compact,
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              Text(reviewing.bio,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: KeleleColors.grayMid,
                                      height: 1.6)),
                              const SizedBox(height: 12),
                              // Portfolio links
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  if (reviewing.behance.isNotEmpty)
                                    _LinkTag('Behance', reviewing.behance),
                                  if (reviewing.instagram.isNotEmpty)
                                    _LinkTag('Instagram', reviewing.instagram),
                                  if (reviewing.youtube.isNotEmpty)
                                    _LinkTag('YouTube', reviewing.youtube),
                                  if (reviewing.linkedin.isNotEmpty)
                                    _LinkTag('LinkedIn', reviewing.linkedin),
                                  if (reviewing.website.isNotEmpty)
                                    _LinkTag('Website', reviewing.website),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                  'Portfolio: ${reviewing.portfolio.length} items',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              // Show portfolio thumbnails
                              if (reviewing.portfolio.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 60,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: reviewing.portfolio.map((p) => Container(
                                      width: 100,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        gradient: p.cover,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(p.title, textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                                      ),
                                    )).toList(),
                                  ),
                                ),
                              ],
                              // Reapply date (for Not Yet)
                              if (reviewing.reapplyAfter.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                      'Reapply after: ${reviewing.reapplyAfter}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: KeleleColors.orange,
                                          fontWeight: FontWeight.w600)),
                                ),
                              const SizedBox(height: 16),
                              // Visibility toggle
                              if (reviewing.status == CreatorStatus.verified)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Text('Public on directory',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                      const SizedBox(width: 8),
                                      Switch(
                                        value: reviewing.isPublic,
                                        activeColor: KeleleColors.green,
                                        onChanged: (_) => ref
                                            .read(creatorsProvider.notifier)
                                            .togglePublic(reviewing.id),
                                      ),
                                    ],
                                  ),
                                ),
                              TextField(
                                controller: _notesC,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: 'Review notes…',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(creatorsProvider.notifier)
                                          .updateStatus(
                                            reviewing.id,
                                            CreatorStatus.verified,
                                            notes: _notesC.text,
                                            reviewer: 'Tobi',
                                          );
                                      _notesC.clear();
                                      setState(() => _reviewingId = null);
                                    },
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('Approve'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: KeleleColors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // Calculate reapply date (6 months from now)
                                      final reapply = DateTime.now()
                                          .add(const Duration(days: 180))
                                          .toIso8601String()
                                          .substring(0, 10);
                                      ref
                                          .read(creatorsProvider.notifier)
                                          .updateStatus(
                                            reviewing.id,
                                            CreatorStatus.notYet,
                                            notes: _notesC.text,
                                            reviewer: 'Tobi',
                                            reapplyAfter: reapply,
                                          );
                                      final savedNotes = _notesC.text;
                                      _notesC.clear();
                                      setState(() {
                                        _reviewingId = null;
                                        _showNotYetTemplate = true;
                                        _notYetName = reviewing.name;
                                        _notYetNotes = savedNotes;
                                      });
                                    },
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text('Not Yet'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: KeleleColors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(creatorsProvider.notifier)
                                          .updateStatus(
                                            reviewing.id,
                                            CreatorStatus.notYet,
                                            notes: _notesC.text,
                                            reviewer: 'Tobi',
                                          );
                                      _notesC.clear();
                                      setState(() => _reviewingId = null);
                                    },
                                    icon: const Icon(Icons.block, size: 18),
                                    label: const Text('Reject'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: KeleleColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (c != filtered.last) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),

            // "Not Yet" email template
            if (_showNotYetTemplate) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: KeleleColors.orangeGlow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KeleleColors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.email_outlined, color: KeleleColors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text('"Not Yet" Feedback Ready',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 16, fontWeight: FontWeight.w700, color: KeleleColors.orange)),
                        const Spacer(),
                        IconButton(
                          onPressed: () => setState(() => _showNotYetTemplate = false),
                          icon: Icon(Icons.close, size: 18, color: KeleleColors.grayMid),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        'Subject: Your Kelele Collective Application\n\n'
                        'Hi $_notYetName,\n\n'
                        'Thanks for applying to be listed on Kelele Collective — we\'re glad you want to be part of this.\n\n'
                        'After reviewing your profile, we\'re not able to verify you just yet. Here\'s why:\n\n'
                        '${_notYetNotes.isNotEmpty ? _notYetNotes : '[Add specific feedback here]'}\n\n'
                        'This isn\'t a "no" — it\'s a "not yet." You\'re welcome to reapply in 3-6 months with updated work. In the meantime, keep creating.\n\n'
                        'If you\'d like feedback or mentorship, join us at our next Multimedia Meetup — details at kelelecollective.org.\n\n'
                        'Best,\nTobi / Kelele Collective',
                        style: const TextStyle(fontSize: 13, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy Template'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.email_outlined, size: 16),
                          label: const Text('Open in Email'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color, bg;
  const _StatCard(this.label, this.value, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 24, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, value, current;
  final ValueChanged<String> onChanged;
  const _FilterChip(this.label, this.value, this.current, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Chip(
        label: Text(label),
        backgroundColor: active ? KeleleColors.dark : KeleleColors.grayLight,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: active ? Colors.white : KeleleColors.dark,
        ),
      ),
    );
  }
}

class _LinkTag extends StatelessWidget {
  final String label, url;
  const _LinkTag(this.label, this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KeleleColors.grayBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link, size: 12, color: KeleleColors.pink),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
