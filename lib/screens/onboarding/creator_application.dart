import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/creator.dart';
import '../../data/mock_data.dart';
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

  // Step 1: Personal info
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _whatsappC = TextEditingController();
  final _companyC = TextEditingController();
  final _locationC = TextEditingController(text: 'Kampala');
  final _bioC = TextEditingController();

  // Step 2: Skills
  String? _primarySkill;
  final Set<String> _sideSkills = {};
  PriceRange _priceRange = PriceRange.mid;

  // Step 3: Portfolio links
  final _behanceC = TextEditingController();
  final _instagramC = TextEditingController();
  final _youtubeC = TextEditingController();
  final _linkedinC = TextEditingController();
  final _websiteC = TextEditingController();
  final _otherC = TextEditingController();

  // Step 4: Work samples
  final List<_WorkSample> _samples = [
    _WorkSample(),
    _WorkSample(),
    _WorkSample(),
  ];

  final _steps = const [
    'About You',
    'Skills',
    'Portfolio Links',
    'Work Samples',
    'Review & Submit',
  ];

  bool get _canProceed {
    switch (_step) {
      case 0:
        return _nameC.text.trim().isNotEmpty &&
            _emailC.text.trim().isNotEmpty &&
            _phoneC.text.trim().isNotEmpty &&
            _bioC.text.trim().isNotEmpty;
      case 1:
        return _primarySkill != null;
      case 2:
        return true; // Links are optional
      case 3:
        return _samples
                .where((s) =>
                    s.titleC.text.trim().isNotEmpty &&
                    s.urlC.text.trim().isNotEmpty)
                .length >=
            3;
      default:
        return true;
    }
  }

  void _submit() {
    final notifier = ref.read(creatorsProvider.notifier);
    final name = _nameC.text.trim();
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();

    final allSkills = [_primarySkill!, ..._sideSkills];

    final portfolioItems = _samples
        .where((s) =>
            s.titleC.text.trim().isNotEmpty && s.urlC.text.trim().isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map((e) => PortfolioItem(
              id: 1000 + e.key,
              title: e.value.titleC.text.trim(),
              skill: e.value.skill ?? _primarySkill!,
              url: e.value.urlC.text.trim(),
              cover: _sampleGradients[e.key % _sampleGradients.length],
            ))
        .toList();

    notifier.addCreator(Creator(
      id: notifier.nextId,
      name: name,
      initials: initials,
      companyName: _companyC.text.trim(),
      primarySkill: _primarySkill!,
      skills: allSkills,
      level: 1, // Default — admin will assess
      priceRange: _priceRange,
      bio: _bioC.text.trim(),
      location: _locationC.text.trim(),
      email: _emailC.text.trim(),
      phone: _phoneC.text.trim(),
      whatsapp: _whatsappC.text.trim(),
      status: CreatorStatus.pending,
      isPublic: false,
      portfolio: portfolioItems,
      behance: _behanceC.text.trim(),
      instagram: _instagramC.text.trim(),
      youtube: _youtubeC.text.trim(),
      linkedin: _linkedinC.text.trim(),
      website: _websiteC.text.trim(),
      portfolioOther: _otherC.text.trim(),
    ));

    widget.onComplete();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _whatsappC.dispose();
    _companyC.dispose();
    _locationC.dispose();
    _bioC.dispose();
    _behanceC.dispose();
    _instagramC.dispose();
    _youtubeC.dispose();
    _linkedinC.dispose();
    _websiteC.dispose();
    _otherC.dispose();
    for (final s in _samples) {
      s.titleC.dispose();
      s.urlC.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KeleleColors.grayLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/login'),
        ),
        title: Row(children: [
          Text('Kelele',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          Text('.',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: KeleleColors.pink)),
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

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      case 4:
        return _buildReview();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── STEP 1: ABOUT YOU ──────────────────
  Widget _buildStep1() {
    return _FormCard(
      title: 'Tell us about yourself',
      subtitle:
          'This information helps clients understand who you are. Be authentic — your personality matters.',
      children: [
        _Field('Full Name *', _nameC, hint: 'e.g. Amara Nakato'),
        _Field('Email Address *', _emailC,
            hint: 'you@example.com', type: TextInputType.emailAddress),
        _Field('Phone Number *', _phoneC,
            hint: '+256 700 123 456', type: TextInputType.phone),
        _Field('WhatsApp (if different)', _whatsappC,
            hint: '+256 700 123 456', type: TextInputType.phone),
        _Field('Company Name (optional)', _companyC,
            hint: 'e.g. Studio Oroma'),
        _Field('Location *', _locationC, hint: 'e.g. Kampala'),
        _Field('Bio *', _bioC,
            hint:
                'Tell us what you do, your experience, and what makes your work unique. 2-3 sentences.',
            maxLines: 4),
      ],
    );
  }

  // ─── STEP 2: SKILLS ─────────────────────
  Widget _buildStep2() {
    return _FormCard(
      title: 'What do you do?',
      subtitle:
          'Select your main skill and up to 3 additional side skills. Be honest — we verify these against your portfolio.',
      children: [
        Text('Primary Skill *',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KeleleColors.grayMid)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skillsList.map((s) {
            final selected = _primarySkill == s;
            return GestureDetector(
              onTap: () => setState(() {
                _primarySkill = s;
                _sideSkills.remove(s);
              }),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? KeleleColors.pink : Colors.white,
                  border: Border.all(
                      color:
                          selected ? KeleleColors.pink : KeleleColors.grayBorder),
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

        if (_primarySkill != null) ...[
          const SizedBox(height: 28),
          Text('Side Skills (up to 3)',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KeleleColors.grayMid)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skillsList
                .where((s) => s != _primarySkill)
                .map((s) {
              final selected = _sideSkills.contains(s);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _sideSkills.remove(s);
                  } else if (_sideSkills.length < 3) {
                    _sideSkills.add(s);
                  }
                }),
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
                  child: Text(s,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color:
                            selected ? Colors.white : KeleleColors.dark,
                      )),
                ),
              );
            }).toList(),
          ),
          Text('${_sideSkills.length}/3 selected',
              style:
                  TextStyle(fontSize: 11, color: KeleleColors.grayMid)),
        ],

        const SizedBox(height: 28),
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
                              fontSize: 11, color: KeleleColors.grayMid)),
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

  // ─── STEP 3: PORTFOLIO LINKS ────────────
  Widget _buildStep3() {
    return _FormCard(
      title: 'Where can we find your work?',
      subtitle:
          'Add links to your online portfolios. These help clients explore your full body of work. All fields are optional.',
      children: [
        _Field('Behance', _behanceC, hint: 'https://behance.net/yourname'),
        _Field('Instagram', _instagramC, hint: '@yourhandle'),
        _Field('YouTube', _youtubeC, hint: 'https://youtube.com/@yourchannel'),
        _Field('LinkedIn', _linkedinC,
            hint: 'https://linkedin.com/in/yourname'),
        _Field('Website', _websiteC, hint: 'https://yoursite.com'),
        _Field('Other Link', _otherC,
            hint: 'ArtStation, Vimeo, SoundCloud, etc.'),
      ],
    );
  }

  // ─── STEP 4: WORK SAMPLES ──────────────
  Widget _buildStep4() {
    final allSkills = [
      if (_primarySkill != null) _primarySkill!,
      ..._sideSkills
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
                  value: s.skill,
                  decoration:
                      const InputDecoration(hintText: 'Skill demonstrated'),
                  items: allSkills
                      .map((sk) =>
                          DropdownMenuItem(value: sk, child: Text(sk)))
                      .toList(),
                  onChanged: (v) => setState(() => s.skill = v),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: s.urlC,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                      hintText:
                          'Link — Behance, Vimeo, YouTube, Google Drive, etc.'),
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
            border: Border.all(color: KeleleColors.orange.withOpacity(0.3)),
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
                  style: TextStyle(fontSize: 12, color: KeleleColors.orange, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── STEP 5: REVIEW ────────────────────
  Widget _buildReview() {
    final completeSamples = _samples
        .where((s) =>
            s.titleC.text.trim().isNotEmpty && s.urlC.text.trim().isNotEmpty)
        .toList();

    return Column(
      children: [
        _FormCard(
          title: 'Review your application',
          subtitle:
              "Make sure everything looks right before submitting. Once submitted, our team will review your profile — you'll hear back within a few days.",
          children: [
            _ReviewRow('Name', _nameC.text),
            _ReviewRow('Email', _emailC.text),
            _ReviewRow('Phone', _phoneC.text),
            if (_whatsappC.text.isNotEmpty)
              _ReviewRow('WhatsApp', _whatsappC.text),
            if (_companyC.text.isNotEmpty)
              _ReviewRow('Company', _companyC.text),
            _ReviewRow('Location', _locationC.text),
            _ReviewRow('Bio', _bioC.text),
          ],
        ),
        const SizedBox(height: 16),
        _FormCard(
          title: 'Skills & Pricing',
          children: [
            _ReviewRow('Primary Skill', _primarySkill ?? ''),
            if (_sideSkills.isNotEmpty)
              _ReviewRow('Side Skills', _sideSkills.join(', ')),
            _ReviewRow(
                'Price Range',
                _priceRange == PriceRange.budget
                    ? 'Budget'
                    : _priceRange == PriceRange.mid
                        ? 'Mid-range'
                        : 'Premium'),
          ],
        ),
        const SizedBox(height: 16),
        _FormCard(
          title: 'Portfolio Links',
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
            if ([_behanceC, _instagramC, _youtubeC, _linkedinC, _websiteC]
                .every((c) => c.text.isEmpty))
              Text('No links provided',
                  style: TextStyle(
                      fontSize: 13, color: KeleleColors.grayMid)),
          ],
        ),
        const SizedBox(height: 16),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.titleC.text,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              Text(s.skill ?? _primarySkill ?? '',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: KeleleColors.grayMid)),
                            ],
                          ),
                        ),
                        Icon(Icons.link,
                            size: 16, color: KeleleColors.pink),
                      ],
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KeleleColors.greenGlow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KeleleColors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: KeleleColors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "By submitting, you agree to Kelele Collective's creator terms. We'll review your application and notify you of the outcome.",
                  style: TextStyle(fontSize: 13, color: KeleleColors.green, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── HELPERS ──────────────────────────────

class _WorkSample {
  final TextEditingController titleC = TextEditingController();
  final TextEditingController urlC = TextEditingController();
  String? skill;
}

final _sampleGradients = [
  const LinearGradient(
      colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
  const LinearGradient(
      colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
  const LinearGradient(
      colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
  const LinearGradient(
      colors: [Color(0xFF43e97b), Color(0xFF38f9d7)]),
  const LinearGradient(
      colors: [Color(0xFFfa709a), Color(0xFFfee140)]),
  const LinearGradient(
      colors: [Color(0xFF30cfd0), Color(0xFF330867)]),
  const LinearGradient(
      colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)]),
  const LinearGradient(
      colors: [Color(0xFFffecd2), Color(0xFFfcb69f)]),
];

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
            // Connector line
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
                            fontSize: 12,
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
                      fontSize: 10,
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

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? type;
  final int maxLines;
  const _Field(this.label, this.controller,
      {this.hint, this.type, this.maxLines = 1});

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
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

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
