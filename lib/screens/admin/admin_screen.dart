import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config.dart';
import '../../data/mock_data.dart';
import '../../models/creator.dart';
import '../../providers/creator_provider.dart';
import '../../services/seed_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

enum _AdminFilter { all, pending, verified, emerging, notYet, rejected }

class _AdminScreenState extends ConsumerState<AdminScreen> {
  _AdminFilter _filter = _AdminFilter.all;
  String? _reviewingId;
  bool _seeding = false;
  final _notesC = TextEditingController();
  bool _showNotYetTemplate = false;
  String _notYetName = '';
  String _notYetEmail = '';
  String _notYetNotes = '';
  // Vetting checklist state per creator
  final Map<String, Set<int>> _vettingChecks = {};

  static const _vettingStages = [
    'Authenticity & Legitimacy — Real person, real work, no AI-generated content',
    'Portfolio Quality & Skill Accuracy — Work matches claimed skill level',
    'Recency — Work produced within the last 2 years',
    'Network Connection — Known in the community (bonus signal)',
  ];

  void _updateMockCreator(String id, Map<String, dynamic> fields) {
    final idx = mockCreators.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    final current = mockCreators[idx];
    final status = fields['status'] != null
        ? CreatorStatus.values.firstWhere((s) => s.name == fields['status'])
        : null;
    mockCreators[idx] = current.copyWith(
      status: status,
      reviewNotes: fields['reviewNotes'] as String?,
      reviewedBy: fields['reviewedBy'] as String?,
      reviewedAt: fields['reviewedAt'] as String?,
      reapplyAfter: fields['reapplyAfter'] as String?,
      isPublic: fields['isPublic'] as bool?,
    );
    ref.invalidate(creatorsProvider);
  }

  @override
  void dispose() {
    _notesC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creators = ref.watch(creatorsProvider);
    // Single-pass status counts
    var verified = 0, emergingCount = 0, pending = 0, notYetCount = 0, rejectedCount = 0;
    for (final c in creators) {
      switch (c.status) {
        case CreatorStatus.verified: verified++;
        case CreatorStatus.verifiedEmerging: emergingCount++;
        case CreatorStatus.pending: pending++;
        case CreatorStatus.notYet: notYetCount++;
        case CreatorStatus.rejected: rejectedCount++;
      }
    }

    final filtered = switch (_filter) {
      _AdminFilter.all => creators,
      _AdminFilter.pending => creators.where((c) => c.status == CreatorStatus.pending).toList(),
      _AdminFilter.verified => creators.where((c) => c.status == CreatorStatus.verified).toList(),
      _AdminFilter.emerging => creators.where((c) => c.status == CreatorStatus.verifiedEmerging).toList(),
      _AdminFilter.notYet => creators.where((c) => c.status == CreatorStatus.notYet).toList(),
      _AdminFilter.rejected => creators.where((c) => c.status == CreatorStatus.rejected).toList(),
    };

    final reviewing =
        _reviewingId != null ? creators.where((c) => c.id == _reviewingId).firstOrNull : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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

            // Seed button — only when database is empty
            if (creators.isEmpty && !useMockData)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton.icon(
                  onPressed: _seeding ? null : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => _seeding = true);
                    try {
                      final seed = SeedService();
                      await seed.seedCreators();
                      await seed.ensureAdminAccount();
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Database seeded with 10 creators + admin account')),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Seed failed: $e')),
                      );
                    }
                    if (mounted) setState(() => _seeding = false);
                  },
                  icon: _seeding
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.cloud_upload, size: 18),
                  label: Text(_seeding ? 'Seeding...' : 'Seed Database with Sample Creators'),
                  style: ElevatedButton.styleFrom(backgroundColor: KeleleColors.pink),
                ),
              ),

            // Stats row
            Row(
              children: [
                _StatCard('Verified', '$verified', KeleleColors.green, KeleleColors.greenGlow),
                const SizedBox(width: 12),
                _StatCard('Emerging', '$emergingCount', const Color(0xFF00897B), const Color(0xFFE0F7FA)),
                const SizedBox(width: 12),
                _StatCard('Pending', '$pending', KeleleColors.orange, KeleleColors.orangeGlow),
                const SizedBox(width: 12),
                _StatCard('Not Yet', '$notYetCount', KeleleColors.orange, KeleleColors.orangeGlow),
                const SizedBox(width: 12),
                _StatCard('Rejected', '$rejectedCount', KeleleColors.red, KeleleColors.redGlow),
                const SizedBox(width: 12),
                _StatCard('Total', '${creators.length}', KeleleColors.dark, KeleleColors.grayLight),
              ],
            ),
            const SizedBox(height: 28),

            // Filter chips
            Wrap(
              spacing: 8,
              children: [
                _FilterChip('All', _AdminFilter.all, _filter, (v) => setState(() => _filter = v)),
                _FilterChip('Pending', _AdminFilter.pending, _filter, (v) => setState(() => _filter = v)),
                _FilterChip('Verified', _AdminFilter.verified, _filter, (v) => setState(() => _filter = v)),
                _FilterChip('Emerging', _AdminFilter.emerging, _filter, (v) => setState(() => _filter = v)),
                _FilterChip('Not Yet', _AdminFilter.notYet, _filter, (v) => setState(() => _filter = v)),
                _FilterChip('Rejected', _AdminFilter.rejected, _filter, (v) => setState(() => _filter = v)),
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
                                        fontSize: 14,
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
                                        '${c.mainSkill.discipline} · ${c.location}',
                                        style: TextStyle(
                                            fontSize: 14,
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
                                            fontSize: 14,
                                            color: KeleleColors.grayMid)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('${reviewing.email} · ${reviewing.phone}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: KeleleColors.grayMid)),
                                  if (reviewing.whatsapp.isNotEmpty) ...[
                                    Text(' · WA: ${reviewing.whatsapp}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: KeleleColors.green)),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  reviewing.mainSkill.discipline,
                                  ...reviewing.sideSkills.map((s) => s.discipline),
                                ]
                                    .map((s) => Chip(
                                          label: Text(s),
                                          padding: EdgeInsets.zero,
                                          labelStyle:
                                              const TextStyle(fontSize: 14),
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
                                        image: p.hasCoverImage
                                            ? DecorationImage(
                                                image: NetworkImage(p.coverImageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(p.title, textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
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
                                          fontSize: 14,
                                          color: KeleleColors.orange,
                                          fontWeight: FontWeight.w600)),
                                ),
                              const SizedBox(height: 16),
                              // Visibility toggle
                              if (reviewing.status == CreatorStatus.verified || reviewing.status == CreatorStatus.verifiedEmerging)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      const Text('Public on directory',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                      const SizedBox(width: 8),
                                      Switch(
                                        value: reviewing.isPublic,
                                        activeTrackColor: KeleleColors.green,
                                        onChanged: (_) async {
                                          if (useMockData) {
                                            _updateMockCreator(reviewing.id, {
                                              'isPublic': !reviewing.isPublic,
                                            });
                                            setState(() {});
                                          } else {
                                            await ref
                                                .read(creatorServiceProvider)
                                                .togglePublic(reviewing.id, !reviewing.isPublic);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                              // ─── Vetting Checklist ───────────────
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: KeleleColors.grayBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Vetting Checklist',
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 13, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 8),
                                    ...List.generate(_vettingStages.length, (i) {
                                      final checks = _vettingChecks[reviewing.id] ?? {};
                                      return InkWell(
                                        onTap: () => setState(() {
                                          final set = _vettingChecks[reviewing.id] ??= {};
                                          if (set.contains(i)) {
                                            set.remove(i);
                                          } else {
                                            set.add(i);
                                          }
                                        }),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                checks.contains(i)
                                                    ? Icons.check_box
                                                    : Icons.check_box_outline_blank,
                                                size: 18,
                                                color: checks.contains(i)
                                                    ? KeleleColors.green
                                                    : KeleleColors.grayMid,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _vettingStages[i],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: checks.contains(i)
                                                        ? KeleleColors.dark
                                                        : KeleleColors.grayMid,
                                                  ),
                                                ),
                                              ),
                                              if (i == 3)
                                                Container(
                                                  margin: const EdgeInsets.only(left: 6),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 6, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: KeleleColors.grayLight,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text('bonus',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: KeleleColors.grayMid)),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
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
                                  // ── Approve ──
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final fields = {
                                        'status': CreatorStatus.verified.name,
                                        'reviewNotes': _notesC.text,
                                        'reviewedBy': 'Tobi',
                                        'reviewedAt': DateTime.now().toIso8601String().split('T').first,
                                        'isPublic': true,
                                      };
                                      if (useMockData) {
                                        _updateMockCreator(reviewing.id, fields);
                                      } else {
                                        await ref.read(creatorServiceProvider).updateStatus(reviewing.id, fields);
                                      }
                                      _vettingChecks.remove(reviewing.id);
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
                                  // ── Approve as Emerging ──
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final fields = {
                                        'status': CreatorStatus.verifiedEmerging.name,
                                        'reviewNotes': _notesC.text,
                                        'reviewedBy': 'Tobi',
                                        'reviewedAt': DateTime.now().toIso8601String().split('T').first,
                                        'isPublic': true,
                                      };
                                      if (useMockData) {
                                        _updateMockCreator(reviewing.id, fields);
                                      } else {
                                        await ref.read(creatorServiceProvider).updateStatus(reviewing.id, fields);
                                      }
                                      _vettingChecks.remove(reviewing.id);
                                      _notesC.clear();
                                      setState(() => _reviewingId = null);
                                    },
                                    icon: const Icon(Icons.trending_up, size: 18),
                                    label: const Text('Emerging'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00897B),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // ── Not Yet (soft reject — feedback + reapply soon) ──
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final reapply = DateTime.now()
                                          .add(const Duration(days: 30))
                                          .toIso8601String()
                                          .substring(0, 10);
                                      final fields = {
                                        'status': CreatorStatus.notYet.name,
                                        'reviewNotes': _notesC.text,
                                        'reviewedBy': 'Tobi',
                                        'reviewedAt': DateTime.now().toIso8601String().split('T').first,
                                        'reapplyAfter': reapply,
                                        'isPublic': false,
                                      };
                                      if (useMockData) {
                                        _updateMockCreator(reviewing.id, fields);
                                      } else {
                                        await ref.read(creatorServiceProvider).updateStatus(reviewing.id, fields);
                                      }
                                      final savedNotes = _notesC.text;
                                      _vettingChecks.remove(reviewing.id);
                                      _notesC.clear();
                                      setState(() {
                                        _reviewingId = null;
                                        _showNotYetTemplate = true;
                                        _notYetName = reviewing.name;
                                        _notYetEmail = reviewing.email;
                                        _notYetNotes = savedNotes;
                                      });
                                    },
                                    icon: const Icon(Icons.pause_circle_outline, size: 18),
                                    label: const Text('Not Yet'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: KeleleColors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // ── Reject (hard — substandard, 3-month wait) ──
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final reapply = DateTime.now()
                                          .add(const Duration(days: 90))
                                          .toIso8601String()
                                          .substring(0, 10);
                                      final fields = {
                                        'status': CreatorStatus.rejected.name,
                                        'reviewNotes': _notesC.text,
                                        'reviewedBy': 'Tobi',
                                        'reviewedAt': DateTime.now().toIso8601String().split('T').first,
                                        'reapplyAfter': reapply,
                                        'isPublic': false,
                                      };
                                      if (useMockData) {
                                        _updateMockCreator(reviewing.id, fields);
                                      } else {
                                        await ref.read(creatorServiceProvider).updateStatus(reviewing.id, fields);
                                      }
                                      _vettingChecks.remove(reviewing.id);
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
                  border: Border.all(color: KeleleColors.orange.withValues(alpha: 0.3)),
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
                          onPressed: () {
                            final template =
                                'Subject: Your Kelele Collective Application\n\n'
                                'Hi $_notYetName,\n\n'
                                'Thanks for applying to be listed on Kelele Collective — we\'re glad you want to be part of this.\n\n'
                                'After reviewing your profile, we\'re not able to verify you just yet. Here\'s why:\n\n'
                                '${_notYetNotes.isNotEmpty ? _notYetNotes : '[Add specific feedback here]'}\n\n'
                                'This isn\'t a "no" — it\'s a "not yet." You\'re welcome to reapply in 3-6 months with updated work. In the meantime, keep creating.\n\n'
                                'If you\'d like feedback or mentorship, join us at our next Multimedia Meetup — details at kelelecollective.org.\n\n'
                                'Best,\nTobi / Kelele Collective';
                            Clipboard.setData(ClipboardData(text: template));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Template copied to clipboard')),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy Template'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            final body = Uri.encodeComponent(
                                'Hi $_notYetName,\n\n'
                                'Thanks for applying to be listed on Kelele Collective — we\'re glad you want to be part of this.\n\n'
                                'After reviewing your profile, we\'re not able to verify you just yet. Here\'s why:\n\n'
                                '${_notYetNotes.isNotEmpty ? _notYetNotes : '[Add specific feedback here]'}\n\n'
                                'This isn\'t a "no" — it\'s a "not yet." You\'re welcome to reapply in 3-6 months with updated work. In the meantime, keep creating.\n\n'
                                'If you\'d like feedback or mentorship, join us at our next Multimedia Meetup — details at kelelecollective.org.\n\n'
                                'Best,\nTobi / Kelele Collective');
                            launchUrl(Uri.parse(
                                'mailto:$_notYetEmail?subject=Your%20Kelele%20Collective%20Application&body=$body'));
                          },
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
                style: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final _AdminFilter value, current;
  final ValueChanged<_AdminFilter> onChanged;
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
