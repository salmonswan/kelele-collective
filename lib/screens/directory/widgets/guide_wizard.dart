import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/mock_data.dart';
import '../../../models/creator.dart';
import '../../../providers/creator_provider.dart';
import '../../../theme/app_theme.dart';

class GuideWizard extends StatefulWidget {
  final WidgetRef ref;
  const GuideWizard({super.key, required this.ref});

  @override
  State<GuideWizard> createState() => _GuideWizardState();
}

class _GuideWizardState extends State<GuideWizard> {
  int _step = 0;
  String? _selectedSkill;
  PriceRange? _selectedPrice;
  String? _selectedLocation;
  int? _selectedLevel;

  static const _totalSteps = 4;

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _apply();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _apply() {
    final ref = widget.ref;
    if (_selectedSkill != null) {
      ref.read(selectedSkillProvider.notifier).state = _selectedSkill;
    }
    if (_selectedPrice != null) {
      ref.read(selectedPriceProvider.notifier).state = _selectedPrice;
    }
    if (_selectedLocation != null) {
      ref.read(selectedLocationProvider.notifier).state = _selectedLocation;
    }
    if (_selectedLevel != null) {
      ref.read(selectedLevelProvider.notifier).state = _selectedLevel;
    }
    Navigator.of(context).pop();
  }

  void _skip() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final locations = widget.ref.read(locationsProvider);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 460,
          constraints: const BoxConstraints(maxHeight: 520),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Header ───────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find your match',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Answer a few quick questions to filter the directory.',
                            style: TextStyle(
                                fontSize: 13, color: KeleleColors.grayMid),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _skip,
                      icon: const Icon(Icons.close, size: 20),
                      style: IconButton.styleFrom(
                        foregroundColor: KeleleColors.grayMid,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Step indicator dots ──────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalSteps, (i) {
                  final active = i == _step;
                  final done = i < _step;
                  return Container(
                    width: active ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: active
                          ? KeleleColors.pink
                          : done
                              ? KeleleColors.pinkLight
                              : KeleleColors.grayBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // ─── Step content ─────────────────
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    key: ValueKey(_step),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _buildStep(locations),
                  ),
                ),
              ),

              // ─── Footer ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: KeleleColors.grayMid,
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                      child: const Text('Skip'),
                    ),
                    const Spacer(),
                    if (_step > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: OutlinedButton(
                          onPressed: _back,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                          _step == _totalSteps - 1 ? 'Find Creators' : 'Next'),
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

  Widget _buildStep(List<String> locations) {
    switch (_step) {
      case 0:
        return _StepSkill(
          selected: _selectedSkill,
          onSelect: (v) => setState(() => _selectedSkill = v),
        );
      case 1:
        return _StepBudget(
          selected: _selectedPrice,
          onSelect: (v) => setState(() => _selectedPrice = v),
        );
      case 2:
        return _StepLocation(
          locations: locations,
          selected: _selectedLocation,
          onSelect: (v) => setState(() => _selectedLocation = v),
        );
      case 3:
        return _StepExperience(
          selected: _selectedLevel,
          onSelect: (v) => setState(() => _selectedLevel = v),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Step 1: Skill ──────────────────────────────
class _StepSkill extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelect;
  const _StepSkill({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What kind of creative do you need?',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skillsList.map((skill) {
            final active = selected == skill;
            return GestureDetector(
              onTap: () => onSelect(active ? null : skill),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? KeleleColors.pink : KeleleColors.grayLight,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: active ? KeleleColors.pink : KeleleColors.grayBorder,
                  ),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: active ? Colors.white : KeleleColors.dark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Step 2: Budget ─────────────────────────────
class _StepBudget extends StatelessWidget {
  final PriceRange? selected;
  final ValueChanged<PriceRange?> onSelect;
  const _StepBudget({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What's your budget?",
            style: GoogleFonts.spaceGrotesk(
                fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        ...[
          (PriceRange.budget, 'Budget', 'Affordable rates, great value'),
          (PriceRange.mid, 'Mid-range', 'Balanced quality and cost'),
          (PriceRange.premium, 'Premium', 'Top-tier talent, premium rates'),
        ].map((e) {
          final active = selected == e.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => onSelect(active ? null : e.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: active ? KeleleColors.pinkGlow : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        active ? KeleleColors.pink : KeleleColors.grayBorder,
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.$2,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? KeleleColors.pink
                                      : KeleleColors.dark)),
                          Text(e.$3,
                              style: TextStyle(
                                  fontSize: 14, color: KeleleColors.grayMid)),
                        ],
                      ),
                    ),
                    if (active)
                      const Icon(Icons.check_circle,
                          size: 20, color: KeleleColors.pink),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Step 3: Location ───────────────────────────
class _StepLocation extends StatelessWidget {
  final List<String> locations;
  final String? selected;
  final ValueChanged<String?> onSelect;
  const _StepLocation(
      {required this.locations,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Where should they be based?',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _locationChip('Anywhere', null),
            ...locations.map((loc) => _locationChip(loc, loc)),
          ],
        ),
      ],
    );
  }

  Widget _locationChip(String label, String? value) {
    final active = selected == value;
    return GestureDetector(
      onTap: () => onSelect(active ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? KeleleColors.pink : KeleleColors.grayLight,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active ? KeleleColors.pink : KeleleColors.grayBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value == null ? Icons.public : Icons.location_on,
              size: 14,
              color: active ? Colors.white : KeleleColors.grayMid,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : KeleleColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 4: Experience ─────────────────────────
class _StepExperience extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onSelect;
  const _StepExperience({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How experienced should they be?',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        ...[
          (1, 'Emerging', 'Fresh talent, building their portfolio'),
          (2, 'Skilled', 'Proven work across multiple projects'),
          (3, 'Expert', 'Top-tier professionals, industry leaders'),
        ].map((e) {
          final active = selected == e.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => onSelect(active ? null : e.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: active ? KeleleColors.pinkGlow : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        active ? KeleleColors.pink : KeleleColors.grayBorder,
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.$2,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? KeleleColors.pink
                                      : KeleleColors.dark)),
                          Text(e.$3,
                              style: TextStyle(
                                  fontSize: 14, color: KeleleColors.grayMid)),
                        ],
                      ),
                    ),
                    if (active)
                      const Icon(Icons.check_circle,
                          size: 20, color: KeleleColors.pink),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
