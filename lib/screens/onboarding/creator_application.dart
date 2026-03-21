import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../config.dart';
import '../../models/creator.dart';
import '../../data/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/creator_provider.dart';
import '../../theme/app_theme.dart';

class CreatorApplicationScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const CreatorApplicationScreen({super.key, required this.onComplete});

  @override
  ConsumerState<CreatorApplicationScreen> createState() =>
      _CreatorApplicationScreenState();
}

class _CreatorApplicationScreenState
    extends ConsumerState<CreatorApplicationScreen> {
  int _step = 0;
  bool _submitted = false;

  // ─── Step 0: About You ──────────────────
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _whatsappC = TextEditingController();
  final _artistNameC = TextEditingController();
  final _companyC = TextEditingController();
  CompanyRole _companyRole = CompanyRole.none;
  final _locationC = TextEditingController(text: 'Kampala');
  final _bioC = TextEditingController();

  // ─── Step 1: Skills & Experience ────────
  String? _mainDiscipline;
  String? _mainSpecification;
  int _mainYears = 1;
  final List<_SideSkillEntry> _sideSkillEntries = [];

  // ─── Step 2: Specialties & Tools ────────
  final Set<Specialty> _specialties = {};
  final Set<String> _software = {};
  final _customSoftwareC = TextEditingController();

  // ─── Step 3: Services & Pricing ─────────
  final _servicesC = TextEditingController();
  final List<TextEditingController> _clientControllers = [];
  PriceRange _priceRange = PriceRange.mid;

  // ─── Step 4: Online Presence ────────────
  final _behanceC = TextEditingController();
  final _instagramC = TextEditingController();
  final _youtubeC = TextEditingController();
  final _linkedinC = TextEditingController();
  final _websiteC = TextEditingController();
  final _otherC = TextEditingController();
  final _featuredVideoC = TextEditingController();
  final List<_ExternalLinkEntry> _externalLinkEntries = [];

  // ─── Step 5: Work Samples ──────────────
  final List<_WorkSample> _samples = [
    _WorkSample(),
    _WorkSample(),
    _WorkSample(),
  ];

  final _steps = const [
    'About You',
    'Skills',
    'Specialties',
    'Services',
    'Links',
    'Samples',
    'Review',
  ];

  bool get _canProceed {
    switch (_step) {
      case 0:
        return _nameC.text.trim().isNotEmpty &&
            _emailC.text.trim().isNotEmpty &&
            _phoneC.text.trim().isNotEmpty &&
            _bioC.text.trim().isNotEmpty;
      case 1:
        return _mainDiscipline != null && _mainYears > 0;
      case 2:
        return true;
      case 3:
        return true;
      case 4:
        return true;
      case 5:
        return _samples
                .where((s) =>
                    s.titleC.text.trim().isNotEmpty &&
                    s.imageBytes != null)
                .length >=
            3;
      default:
        return true;
    }
  }

  Future<void> _submit() async {
    final name = _nameC.text.trim();
    final initials = buildInitials(name);

    final mainSkillMap = {
      'discipline': _mainDiscipline!,
      'specification': _mainSpecification,
      'yearsOfExperience': _mainYears,
    };

    final sideSkillMaps = _sideSkillEntries
        .where((e) => e.discipline != null)
        .map((e) => {
              'discipline': e.discipline!,
              'specification': e.specification,
              'yearsOfExperience': e.yearsOfExperience,
            })
        .toList();

    final portfolioItems = _samples
        .where((s) =>
            s.titleC.text.trim().isNotEmpty && s.imageBytes != null)
        .toList()
        .asMap()
        .entries
        .map((e) {
      final grad = _sampleGradients[e.key % _sampleGradients.length];
      final coverColors = grad.colors
          .map((c) =>
              '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}')
          .toList();
      // Encode image as data URI for mock mode; Firebase mode would upload to Storage
      final coverImageUrl = e.value.imageBytes != null
          ? 'data:image/jpeg;base64,${base64Encode(e.value.imageBytes!)}'
          : '';
      return {
        'id': 'sample_${e.key}',
        'title': e.value.titleC.text.trim(),
        'skill': e.value.skill ?? _mainDiscipline!,
        'url': '',
        'coverImageUrl': coverImageUrl,
        'coverColors': coverColors,
      };
    }).toList();

    final videoUrl = _featuredVideoC.text.trim();

    final extLinks = _externalLinkEntries
        .where((e) =>
            e.labelC.text.trim().isNotEmpty && e.urlC.text.trim().isNotEmpty)
        .map((e) => {
              'label': e.labelC.text.trim(),
              'url': e.urlC.text.trim(),
            })
        .toList();

    final clients = _clientControllers
        .map((c) => c.text.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    final creatorData = {
      'userId': ref.read(currentUserProvider)?.uid,
      'name': name,
      'initials': initials,
      'artistName':
          _artistNameC.text.trim().isEmpty ? null : _artistNameC.text.trim(),
      'companyName': _companyC.text.trim(),
      'companyRole': _companyRole.name,
      // New skill fields
      'mainSkill': mainSkillMap,
      'sideSkills': sideSkillMaps,
      // Deprecated fields (backward compat)
      'primarySkill': _mainDiscipline!,
      'skills': [
        _mainDiscipline!,
        ...sideSkillMaps.map((m) => m['discipline']),
      ],
      'level': Creator.experienceToLevel(_mainYears),
      // New expertise fields
      'specialties': _specialties.map((s) => s.name).toList(),
      'software': _software.toList(),
      'services': _servicesC.text.trim(),
      'clients': clients,
      'featuredVideoUrls': videoUrl.isNotEmpty ? [videoUrl] : <String>[],
      'externalLinks': extLinks,
      // Existing fields
      'priceRange': _priceRange.name,
      'bio': _bioC.text.trim(),
      'location': _locationC.text.trim(),
      'email': _emailC.text.trim(),
      'phone': _phoneC.text.trim(),
      'whatsapp': _whatsappC.text.trim(),
      'status': CreatorStatus.pending.name,
      'isPublic': false,
      'featured': false,
      'profilePhotoUrl': '',
      'portfolio': portfolioItems,
      'behance': _behanceC.text.trim(),
      'instagram': _instagramC.text.trim(),
      'youtube': _youtubeC.text.trim(),
      'linkedin': _linkedinC.text.trim(),
      'website': _websiteC.text.trim(),
      'portfolioOther': _otherC.text.trim(),
      'reviewNotes': '',
      'reviewedBy': '',
      'reviewedAt': '',
      'reapplyAfter': '',
    };

    if (useMockData) {
      // In mock mode, build a Creator object and add to the mock list
      final id = 'mock_${DateTime.now().millisecondsSinceEpoch}';
      mockCreators.add(Creator.fromFirestore(id, creatorData));
      if (mounted) setState(() => _submitted = true);
      return;
    }

    await ref.read(creatorServiceProvider).addCreator(creatorData);
    widget.onComplete();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _whatsappC.dispose();
    _artistNameC.dispose();
    _companyC.dispose();
    _locationC.dispose();
    _bioC.dispose();
    _customSoftwareC.dispose();
    _servicesC.dispose();
    for (final c in _clientControllers) {
      c.dispose();
    }
    _behanceC.dispose();
    _instagramC.dispose();
    _youtubeC.dispose();
    _linkedinC.dispose();
    _websiteC.dispose();
    _otherC.dispose();
    _featuredVideoC.dispose();
    for (final e in _externalLinkEntries) {
      e.labelC.dispose();
      e.urlC.dispose();
    }
    for (final s in _samples) {
      s.titleC.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: KeleleColors.grayLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/login'),
        ),
        title: Row(children: [
          Image.asset(
            'assets/brand/k-empower-pos.png',
            height: 40,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(width: 12),
          Text('Creator Application',
              style: TextStyle(fontSize: 14, color: KeleleColors.grayMid)),
        ]),
      ),
      body: Column(
        children: [
          // Progress
          _StepIndicator(steps: _steps, current: _step),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _buildStep(),
                ),
              ),
            ),
          ),

          // Navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: KeleleColors.grayBorder)),
            ),
            child: Row(
              children: [
                if (_step > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    child: const Text('Back'),
                  ),
                const Spacer(),
                Text('${_step + 1} of ${_steps.length}',
                    style: TextStyle(
                        fontSize: 13, color: KeleleColors.grayMid)),
                const SizedBox(width: 16),
                if (_step < _steps.length - 1)
                  ElevatedButton(
                    onPressed: _canProceed
                        ? () => setState(() => _step++)
                        : null,
                    child: const Text('Continue'),
                  )
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KeleleColors.green,
                    ),
                    child: const Text('Submit Application'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    final firstName = _nameC.text.trim().split(' ').first;
    return Scaffold(
      backgroundColor: KeleleColors.grayLight,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: KeleleColors.greenGlow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.check_circle,
                      size: 52, color: KeleleColors.green),
                ),
                const SizedBox(height: 28),
                Text(
                  'Application Submitted!',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thanks, $firstName! Your application is now pending review. '
                  'Our team will check your portfolio and get back to you at ${_emailC.text.trim()}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: KeleleColors.grayMid, height: 1.6),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: KeleleColors.pinkGlow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: KeleleColors.pink),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your profile will appear in the directory once verified by our team.',
                          style: TextStyle(
                              fontSize: 13,
                              color: KeleleColors.pinkDark,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildAboutYou();
      case 1:
        return _buildSkills();
      case 2:
        return _buildSpecialties();
      case 3:
        return _buildServices();
      case 4:
        return _buildLinks();
      case 5:
        return _buildWorkSamples();
      case 6:
        return _buildReview();
      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 0: ABOUT YOU
  // ═══════════════════════════════════════════════════════

  Widget _buildAboutYou() {
    return _FormCard(
      title: 'Tell us about yourself',
      subtitle:
          'This information helps clients understand who you are. Be authentic — your personality matters.',
      children: [
        _Field('Full Name *', _nameC, hint: 'e.g. Amara Nakato',
            onChanged: (_) => setState(() {})),
        _Field('Artist / Stage Name', _artistNameC,
            hint: 'e.g. DJ Esco, Nyago Arts'),
        _Field('Email Address *', _emailC,
            hint: 'you@example.com', type: TextInputType.emailAddress,
            onChanged: (_) => setState(() {})),
        _Field('Phone Number *', _phoneC,
            hint: '+256 700 123 456', type: TextInputType.phone,
            onChanged: (_) => setState(() {})),
        _Field('WhatsApp (if different)', _whatsappC,
            hint: '+256 700 123 456', type: TextInputType.phone),
        _Field('Company Name', _companyC, hint: 'e.g. Studio Oroma',
            onChanged: (_) => setState(() {})),

        // Company role — only show if company name is set
        if (_companyC.text.trim().isNotEmpty) ...[
          Text('Your Role',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: KeleleColors.grayMid)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CompanyRole.values.map((role) {
              final selected = _companyRole == role;
              final label = switch (role) {
                CompanyRole.founder => 'Founder',
                CompanyRole.coFounder => 'Co-Founder',
                CompanyRole.employee => 'Employee',
                CompanyRole.none => 'N/A',
              };
              return GestureDetector(
                onTap: () => setState(() => _companyRole = role),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? KeleleColors.dark : Colors.white,
                    border: Border.all(
                        color: selected
                            ? KeleleColors.dark
                            : KeleleColors.grayBorder),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : KeleleColors.dark,
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        _Field('Location *', _locationC, hint: 'e.g. Kampala'),
        _Field('Bio *', _bioC,
            hint:
                'Tell us what you do, your experience, and what makes your work unique. 2-3 sentences.',
            maxLines: 4, onChanged: (_) => setState(() {})),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 1: SKILLS & EXPERIENCE
  // ═══════════════════════════════════════════════════════

  Widget _buildSkills() {
    final specs = _mainDiscipline != null
        ? (disciplineSpecifications[_mainDiscipline] ?? [])
        : <String>[];

    return _FormCard(
      title: 'What do you do?',
      subtitle:
          'Select your main discipline and experience level. Be honest — we verify these against your portfolio.',
      children: [
        // ─── Main Discipline ───
        Text('Main Discipline *',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KeleleColors.grayMid)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skillsList.map((s) {
            final selected = _mainDiscipline == s;
            return GestureDetector(
              onTap: () => setState(() {
                _mainDiscipline = s;
                _mainSpecification = null;
                // Remove from side skills if it was there
                _sideSkillEntries.removeWhere((e) => e.discipline == s);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? KeleleColors.pink : Colors.white,
                  border: Border.all(
                      color: selected
                          ? KeleleColors.pink
                          : KeleleColors.grayBorder),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(s,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : KeleleColors.dark,
                    )),
              ),
            );
          }).toList(),
        ),

        // ─── Main Specification (conditional) ───
        if (_mainDiscipline != null && specs.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Specification',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KeleleColors.grayMid)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: specs.map((sp) {
              final selected = _mainSpecification == sp;
              return GestureDetector(
                onTap: () => setState(() {
                  _mainSpecification = selected ? null : sp;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        selected ? KeleleColors.pinkGlow : Colors.white,
                    border: Border.all(
                        color: selected
                            ? KeleleColors.pink
                            : KeleleColors.grayBorder),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(sp,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color:
                            selected ? KeleleColors.pink : KeleleColors.dark,
                      )),
                ),
              );
            }).toList(),
          ),
        ],

        // ─── Main Years of Experience ───
        if (_mainDiscipline != null) ...[
          const SizedBox(height: 20),
          Text('Years of Experience *',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KeleleColors.grayMid)),
          const SizedBox(height: 8),
          Row(
            children: [
              _YearStepper(
                value: _mainYears,
                onChanged: (v) => setState(() => _mainYears = v),
              ),
              const SizedBox(width: 12),
              Text(
                _mainYears <= 2
                    ? 'Emerging'
                    : _mainYears <= 5
                        ? 'Skilled'
                        : 'Expert',
                style: TextStyle(
                    fontSize: 13,
                    color: KeleleColors.grayMid,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],

        // ─── Side Skills ───
        if (_mainDiscipline != null) ...[
          const SizedBox(height: 28),
          Row(
            children: [
              Text('Side Skills',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: KeleleColors.grayMid)),
              const SizedBox(width: 8),
              Text('${_sideSkillEntries.length}/3',
                  style: TextStyle(
                      fontSize: 12, color: KeleleColors.grayMid)),
            ],
          ),
          const SizedBox(height: 8),
          ..._sideSkillEntries.asMap().entries.map((entry) {
            final i = entry.key;
            final skill = entry.value;
            final availableDisciplines = skillsList
                .where((s) =>
                    s != _mainDiscipline &&
                    !_sideSkillEntries
                        .where((e) => e != skill)
                        .any((e) => e.discipline == s))
                .toList();
            final sideSpecs = skill.discipline != null
                ? (disciplineSpecifications[skill.discipline] ?? [])
                : <String>[];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: KeleleColors.grayBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Side Skill ${i + 1}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _sideSkillEntries.removeAt(i)),
                        child: Icon(Icons.close,
                            size: 18, color: KeleleColors.grayMid),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: skill.discipline,
                    decoration:
                        const InputDecoration(hintText: 'Select discipline'),
                    items: availableDisciplines
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      skill.discipline = v;
                      skill.specification = null;
                    }),
                  ),
                  if (sideSpecs.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: skill.specification,
                      decoration: const InputDecoration(
                          hintText: 'Specification (optional)'),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('None')),
                        ...sideSpecs.map((sp) =>
                            DropdownMenuItem(value: sp, child: Text(sp))),
                      ],
                      onChanged: (v) =>
                          setState(() => skill.specification = v),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Years:',
                          style: TextStyle(
                              fontSize: 13, color: KeleleColors.grayMid)),
                      const SizedBox(width: 12),
                      _YearStepper(
                        value: skill.yearsOfExperience,
                        onChanged: (v) =>
                            setState(() => skill.yearsOfExperience = v),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          if (_sideSkillEntries.length < 3)
            OutlinedButton.icon(
              onPressed: () =>
                  setState(() => _sideSkillEntries.add(_SideSkillEntry())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add side skill'),
            ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 2: SPECIALTIES & TOOLS
  // ═══════════════════════════════════════════════════════

  Widget _buildSpecialties() {
    return _FormCard(
      title: 'Industries & Tools',
      subtitle:
          'What industries do you work in, and what tools do you use? This helps clients find the right fit.',
      children: [
        // ─── Specialties ───
        Row(
          children: [
            Text('Specialties',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KeleleColors.grayMid)),
            const SizedBox(width: 8),
            Text('${_specialties.length}/5',
                style:
                    TextStyle(fontSize: 12, color: KeleleColors.grayMid)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Specialty.values.map((sp) {
            final selected = _specialties.contains(sp);
            final label = specialtyLabels[sp] ?? sp.name;
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _specialties.remove(sp);
                } else if (_specialties.length < 5) {
                  _specialties.add(sp);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? KeleleColors.dark : Colors.white,
                  border: Border.all(
                      color: selected
                          ? KeleleColors.dark
                          : KeleleColors.grayBorder),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : KeleleColors.dark,
                    )),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // ─── Software & Tools ───
        Row(
          children: [
            Text('Software & Tools',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KeleleColors.grayMid)),
            const SizedBox(width: 8),
            Text('${_software.length} selected',
                style:
                    TextStyle(fontSize: 12, color: KeleleColors.grayMid)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: softwareList.map((sw) {
            final selected = _software.contains(sw);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _software.remove(sw);
                } else {
                  _software.add(sw);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? KeleleColors.dark : Colors.white,
                  border: Border.all(
                      color: selected
                          ? KeleleColors.dark
                          : KeleleColors.grayBorder),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(sw,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : KeleleColors.dark,
                    )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Custom software entry
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customSoftwareC,
                decoration: const InputDecoration(
                    hintText: 'Add custom tool...'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {
                final val = _customSoftwareC.text.trim();
                if (val.isNotEmpty && !_software.contains(val)) {
                  setState(() {
                    _software.add(val);
                    _customSoftwareC.clear();
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        // Show custom entries as removable chips
        if (_software.where((s) => !softwareList.contains(s)).isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _software
                .where((s) => !softwareList.contains(s))
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: KeleleColors.pinkGlow,
                        border:
                            Border.all(color: KeleleColors.pink),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: KeleleColors.pink)),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _software.remove(s)),
                            child: Icon(Icons.close,
                                size: 14, color: KeleleColors.pink),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 3: SERVICES & PRICING
  // ═══════════════════════════════════════════════════════

  Widget _buildServices() {
    return _FormCard(
      title: 'What do you offer?',
      subtitle:
          'Describe your services and the clients you\'ve worked with. This helps us match you with the right opportunities.',
      children: [
        _Field('Services', _servicesC,
            hint:
                'e.g. Full-service motion design and 3D animation for commercials, explainers, and brand identity.',
            maxLines: 4),

        // ─── Clients ───
        Text('Clients You\'ve Worked With',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: KeleleColors.grayMid)),
        const SizedBox(height: 8),
        ..._clientControllers.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(
                        hintText: 'e.g. MTN Uganda'),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() {
                    _clientControllers[entry.key].dispose();
                    _clientControllers.removeAt(entry.key);
                  }),
                  child: Icon(Icons.close,
                      size: 18, color: KeleleColors.grayMid),
                ),
              ],
            ),
          );
        }),
        if (_clientControllers.length < 10)
          OutlinedButton.icon(
            onPressed: () =>
                setState(() => _clientControllers.add(TextEditingController())),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add client'),
          ),

        const SizedBox(height: 28),

        // ─── Price Range ───
        Text('Price Range',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KeleleColors.grayMid)),
        const SizedBox(height: 8),
        Row(
          children: PriceRange.values.map((pr) {
            final selected = _priceRange == pr;
            final label = pr == PriceRange.budget
                ? 'Budget'
                : pr == PriceRange.mid
                    ? 'Mid-range'
                    : 'Premium';
            final desc = pr == PriceRange.budget
                ? 'Competitive rates'
                : pr == PriceRange.mid
                    ? 'Market standard'
                    : 'Top-tier pricing';
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _priceRange = pr),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected ? KeleleColors.pinkGlow : Colors.white,
                    border: Border.all(
                        color: selected
                            ? KeleleColors.pink
                            : KeleleColors.grayBorder,
                        width: selected ? 2 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(desc,
                          style: TextStyle(
                              fontSize: 13, color: KeleleColors.grayMid)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 4: ONLINE PRESENCE
  // ═══════════════════════════════════════════════════════

  Widget _buildLinks() {
    return _FormCard(
      title: 'Where can we find your work?',
      subtitle:
          'Add links to your online portfolios and featured videos. All fields are optional.',
      children: [
        // ─── Social Links ───
        _Field('Behance', _behanceC, hint: 'https://behance.net/yourname'),
        _Field('Instagram', _instagramC, hint: '@yourhandle'),
        _Field('YouTube', _youtubeC,
            hint: 'https://youtube.com/@yourchannel'),
        _Field('LinkedIn', _linkedinC,
            hint: 'https://linkedin.com/in/yourname'),
        _Field('Website', _websiteC, hint: 'https://yoursite.com'),
        _Field('Other Link', _otherC,
            hint: 'ArtStation, Vimeo, SoundCloud, etc.'),

        const SizedBox(height: 12),

        // ─── Featured Video ───
        _Field('Featured Video', _featuredVideoC,
            hint: 'YouTube or Vimeo URL for your showreel'),

        const SizedBox(height: 20),

        // ─── External Links ───
        Text('Other Resources',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KeleleColors.grayMid)),
        const SizedBox(height: 4),
        Text('PDF portfolio, rate card, press kit, etc.',
            style: TextStyle(fontSize: 13, color: KeleleColors.grayMid)),
        const SizedBox(height: 8),
        ..._externalLinkEntries.asMap().entries.map((entry) {
          final e = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: KeleleColors.grayBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: e.labelC,
                    decoration:
                        const InputDecoration(hintText: 'Label'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: e.urlC,
                    decoration:
                        const InputDecoration(hintText: 'URL'),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() {
                    _externalLinkEntries[entry.key].labelC.dispose();
                    _externalLinkEntries[entry.key].urlC.dispose();
                    _externalLinkEntries.removeAt(entry.key);
                  }),
                  child: Icon(Icons.close,
                      size: 18, color: KeleleColors.grayMid),
                ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () =>
              setState(() => _externalLinkEntries.add(_ExternalLinkEntry())),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add link'),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 5: WORK SAMPLES
  // ═══════════════════════════════════════════════════════

  Widget _buildWorkSamples() {
    final allDisciplines = [
      if (_mainDiscipline != null) _mainDiscipline!,
      ..._sideSkillEntries
          .where((e) => e.discipline != null)
          .map((e) => e.discipline!),
    ];

    return _FormCard(
      title: 'Show us your best work',
      subtitle:
          'Add at least 3 work samples. Each needs a title, the skill it demonstrates, and a link. This is what we review during vetting.',
      children: [
        ...List.generate(_samples.length, (i) {
          final s = _samples[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: KeleleColors.grayBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: KeleleColors.pink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Sample ${i + 1}${i < 3 ? ' *' : ''}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (i >= 3)
                      IconButton(
                        onPressed: () =>
                            setState(() => _samples.removeAt(i)),
                        icon: Icon(Icons.close,
                            size: 18, color: KeleleColors.grayMid),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: s.titleC,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                      hintText: 'Project title, e.g. "MTN Brand Campaign"'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: s.skill,
                  decoration:
                      const InputDecoration(hintText: 'Skill demonstrated'),
                  items: allDisciplines
                      .map((sk) =>
                          DropdownMenuItem(value: sk, child: Text(sk)))
                      .toList(),
                  onChanged: (v) => setState(() => s.skill = v),
                ),
                const SizedBox(height: 10),
                // Image upload area
                if (s.imageBytes != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          s.imageBytes!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            s.imageBytes = null;
                            s.imageName = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      if (s.imageName != null)
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              s.imageName!,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1200,
                        imageQuality: 85,
                      );
                      if (picked != null) {
                        final bytes = await picked.readAsBytes();
                        setState(() {
                          s.imageBytes = bytes;
                          s.imageName = picked.name;
                        });
                      }
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: KeleleColors.grayLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: KeleleColors.grayBorder),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 32, color: KeleleColors.grayMid),
                            const SizedBox(height: 6),
                            Text('Upload cover image',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: KeleleColors.grayMid)),
                            const SizedBox(height: 2),
                            Text('JPG, PNG — max 1200px',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: KeleleColors.grayMid)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        if (_samples.length < 8)
          OutlinedButton.icon(
            onPressed: () => setState(() => _samples.add(_WorkSample())),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add another sample'),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: KeleleColors.orangeGlow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: KeleleColors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  size: 18, color: KeleleColors.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Minimum 3 samples required. Choose your best work — quality over quantity. We recommend recent work (last 2 years).',
                  style: TextStyle(
                      fontSize: 14,
                      color: KeleleColors.orange,
                      height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 6: REVIEW & SUBMIT
  // ═══════════════════════════════════════════════════════

  Widget _buildReview() {
    final completeSamples = _samples
        .where((s) =>
            s.titleC.text.trim().isNotEmpty && s.imageBytes != null)
        .toList();

    final priceLabel = _priceRange == PriceRange.budget
        ? 'Budget'
        : _priceRange == PriceRange.mid
            ? 'Mid-range'
            : 'Premium';

    final clients = _clientControllers
        .map((c) => c.text.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    final videoUrl = _featuredVideoC.text.trim();

    final extLinks = _externalLinkEntries
        .where((e) =>
            e.labelC.text.trim().isNotEmpty && e.urlC.text.trim().isNotEmpty)
        .toList();

    return Column(
      children: [
        // Personal Info
        _FormCard(
          title: 'Personal Info',
          children: [
            _ReviewRow('Name', _nameC.text),
            if (_artistNameC.text.isNotEmpty)
              _ReviewRow('Artist Name', _artistNameC.text),
            _ReviewRow('Email', _emailC.text),
            _ReviewRow('Phone', _phoneC.text),
            if (_whatsappC.text.isNotEmpty)
              _ReviewRow('WhatsApp', _whatsappC.text),
            if (_companyC.text.isNotEmpty) ...[
              _ReviewRow('Company', _companyC.text),
              if (_companyRole != CompanyRole.none)
                _ReviewRow(
                    'Role',
                    switch (_companyRole) {
                      CompanyRole.founder => 'Founder',
                      CompanyRole.coFounder => 'Co-Founder',
                      CompanyRole.employee => 'Employee',
                      CompanyRole.none => '',
                    }),
            ],
            _ReviewRow('Location', _locationC.text),
            _ReviewRow('Bio', _bioC.text),
          ],
        ),
        const SizedBox(height: 16),

        // Skills
        _FormCard(
          title: 'Skills & Experience',
          children: [
            _ReviewRow(
              'Main Skill',
              '$_mainDiscipline${_mainSpecification != null ? ' — $_mainSpecification' : ''} ($_mainYears yrs)',
            ),
            if (_sideSkillEntries.isNotEmpty)
              ..._sideSkillEntries
                  .where((e) => e.discipline != null)
                  .map((e) => _ReviewRow(
                        'Side Skill',
                        '${e.discipline}${e.specification != null ? ' — ${e.specification}' : ''} (${e.yearsOfExperience} yrs)',
                      )),
          ],
        ),
        const SizedBox(height: 16),

        // Specialties & Tools
        if (_specialties.isNotEmpty || _software.isNotEmpty)
          _FormCard(
            title: 'Specialties & Tools',
            children: [
              if (_specialties.isNotEmpty)
                _ReviewRow(
                  'Specialties',
                  _specialties
                      .map((s) => specialtyLabels[s] ?? s.name)
                      .join(', '),
                ),
              if (_software.isNotEmpty)
                _ReviewRow('Software', _software.join(', ')),
            ],
          ),
        if (_specialties.isNotEmpty || _software.isNotEmpty)
          const SizedBox(height: 16),

        // Services & Pricing
        _FormCard(
          title: 'Services & Pricing',
          children: [
            if (_servicesC.text.isNotEmpty)
              _ReviewRow('Services', _servicesC.text),
            if (clients.isNotEmpty)
              _ReviewRow('Clients', clients.join(', ')),
            _ReviewRow('Price Range', priceLabel),
          ],
        ),
        const SizedBox(height: 16),

        // Online Presence
        _FormCard(
          title: 'Online Presence',
          children: [
            if (_behanceC.text.isNotEmpty)
              _ReviewRow('Behance', _behanceC.text),
            if (_instagramC.text.isNotEmpty)
              _ReviewRow('Instagram', _instagramC.text),
            if (_youtubeC.text.isNotEmpty)
              _ReviewRow('YouTube', _youtubeC.text),
            if (_linkedinC.text.isNotEmpty)
              _ReviewRow('LinkedIn', _linkedinC.text),
            if (_websiteC.text.isNotEmpty)
              _ReviewRow('Website', _websiteC.text),
            if (_otherC.text.isNotEmpty)
              _ReviewRow('Other', _otherC.text),
            if (videoUrl.isNotEmpty)
              _ReviewRow('Featured Video', videoUrl),
            if (extLinks.isNotEmpty)
              ...extLinks.map((e) =>
                  _ReviewRow(e.labelC.text.trim(), e.urlC.text.trim())),
            if ([
              _behanceC,
              _instagramC,
              _youtubeC,
              _linkedinC,
              _websiteC,
            ].every((c) => c.text.isEmpty) &&
                videoUrl.isEmpty &&
                extLinks.isEmpty)
              Text('No links provided',
                  style: TextStyle(
                      fontSize: 13, color: KeleleColors.grayMid)),
          ],
        ),
        const SizedBox(height: 16),

        // Work Samples
        _FormCard(
          title: 'Work Samples (${completeSamples.length})',
          children: completeSamples
              .map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: KeleleColors.grayLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (s.imageBytes != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              s.imageBytes!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.titleC.text,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              Text(s.skill ?? _mainDiscipline ?? '',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: KeleleColors.grayMid)),
                            ],
                          ),
                        ),
                        Icon(Icons.image,
                            size: 16, color: KeleleColors.pink),
                      ],
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),

        // Submit notice
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KeleleColors.greenGlow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KeleleColors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: KeleleColors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "By submitting, you agree to Kelele Collective's creator terms. We'll review your application and notify you of the outcome.",
                  style: TextStyle(
                      fontSize: 13,
                      color: KeleleColors.green,
                      height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════

class _SideSkillEntry {
  String? discipline;
  String? specification;
  int yearsOfExperience = 1;
}

class _ExternalLinkEntry {
  final labelC = TextEditingController();
  final urlC = TextEditingController();
}

class _WorkSample {
  final TextEditingController titleC = TextEditingController();
  Uint8List? imageBytes;
  String? imageName;
  String? skill;
}

final _sampleGradients = [
  const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
  const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
  const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
  const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)]),
  const LinearGradient(colors: [Color(0xFFfa709a), Color(0xFFfee140)]),
  const LinearGradient(colors: [Color(0xFF30cfd0), Color(0xFF330867)]),
  const LinearGradient(colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)]),
  const LinearGradient(colors: [Color(0xFFffecd2), Color(0xFFfcb69f)]),
];

// ─── Year Stepper ──────────────────────────────

class _YearStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _YearStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: KeleleColors.grayBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: value > 1 ? () => onChanged(value - 1) : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.remove,
                  size: 18,
                  color: value > 1
                      ? KeleleColors.dark
                      : KeleleColors.grayBorder),
            ),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text('$value',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          GestureDetector(
            onTap: value < 30 ? () => onChanged(value + 1) : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.add,
                  size: 18,
                  color: value < 30
                      ? KeleleColors.dark
                      : KeleleColors.grayBorder),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step Indicator ────────────────────────────

class _StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int current;
  const _StepIndicator({required this.steps, required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: KeleleColors.grayBorder)),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIdx = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIdx < current
                    ? KeleleColors.pink
                    : KeleleColors.grayBorder,
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final done = stepIdx < current;
          final active = stepIdx == current;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done
                      ? KeleleColors.pink
                      : active
                          ? KeleleColors.pinkGlow
                          : KeleleColors.grayLight,
                  shape: BoxShape.circle,
                  border: active
                      ? Border.all(color: KeleleColors.pink, width: 2)
                      : null,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check,
                          size: 14, color: Colors.white)
                      : Text('${stepIdx + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? KeleleColors.pink
                                : KeleleColors.grayMid,
                          )),
                ),
              ),
              const SizedBox(height: 4),
              if (MediaQuery.of(context).size.width > 600)
                Text(steps[stepIdx],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w500,
                      color:
                          active ? KeleleColors.pink : KeleleColors.grayMid,
                    )),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Form Card ─────────────────────────────────

class _FormCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  const _FormCard(
      {required this.title, this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KeleleColors.grayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!,
                style: TextStyle(
                    fontSize: 13,
                    color: KeleleColors.grayMid,
                    height: 1.5)),
          ],
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

// ─── Text Field ────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? type;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  const _Field(this.label, this.controller,
      {this.hint, this.type, this.maxLines = 1, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: KeleleColors.grayMid)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: type,
            maxLines: maxLines,
            onChanged: onChanged,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

// ─── Review Row ────────────────────────────────

class _ReviewRow extends StatelessWidget {
  final String label, value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: KeleleColors.grayMid)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
