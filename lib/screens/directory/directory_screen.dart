import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config.dart';
import '../../models/creator.dart';
import '../../providers/creator_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/project_card.dart';
import 'widgets/people_card.dart';
import 'widgets/project_lightbox.dart';
import 'widgets/guide_wizard.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  ({String projectId, String creatorId})? _lightboxData;

  void _openLightbox(String projectId, String creatorId) =>
      setState(() => _lightboxData = (projectId: projectId, creatorId: creatorId));
  void _closeLightbox() => setState(() => _lightboxData = null);

  bool _guideShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Show guide wizard on first build if provider says to
    if (!_guideShown) {
      _guideShown = true;
      final show = ref.read(showGuideProvider);
      if (show) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showGuide();
        });
      }
    }
  }

  void _showGuide() {
    ref.read(showGuideProvider.notifier).state = false;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => GuideWizard(ref: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(directoryViewProvider);
    final isLoading = !useMockData && ref.watch(creatorsStreamProvider).isLoading;
    final selectedSkill = ref.watch(selectedSkillProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);
    final selectedLevel = ref.watch(selectedLevelProvider);
    final selectedPrice = ref.watch(selectedPriceProvider);
    final filteredProjects = ref.watch(filteredProjectsProvider);
    final hasActiveFilters = selectedSkill != null ||
        selectedLocation != null ||
        selectedLevel != null ||
        selectedPrice != null;

    return Stack(
      children: [
        // Noise texture background
        Positioned.fill(
          child: Opacity(
            opacity: 0.35,
            child: Image.asset(
              'assets/images/noise-light3.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
        Column(
          children: [
            // ─── STICKY TOP BAR ────────────────
            Material(
              elevation: 0,
              color: KeleleColors.white,
              child: Column(
                children: [
                  // Search row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: KeleleColors.grayLight,
                              border:
                                  Border.all(color: KeleleColors.grayBorder),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search,
                                    size: 20, color: KeleleColors.grayMid),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    onChanged: (v) => ref
                                        .read(searchQueryProvider.notifier)
                                        .state = v,
                                    decoration: const InputDecoration(
                                      hintText: 'Search Kelele…',
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      fillColor: Colors.transparent,
                                      filled: true,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Guide button
                        if (view == DirectoryView.people)
                          IconButton(
                            onPressed: _showGuide,
                            icon: const Icon(Icons.explore_outlined),
                            tooltip: 'Find your match',
                            style: IconButton.styleFrom(
                              backgroundColor: KeleleColors.pinkGlow,
                              foregroundColor: KeleleColors.pink,
                            ),
                          ),
                        // Shuffle button
                        if (view == DirectoryView.people)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: IconButton(
                              onPressed: () => ref
                                  .read(shuffleSeedProvider.notifier)
                                  .state = DateTime.now()
                                      .millisecondsSinceEpoch,
                              icon: const Icon(Icons.shuffle),
                              tooltip: 'Shuffle',
                              style: IconButton.styleFrom(
                                backgroundColor: KeleleColors.grayLight,
                                foregroundColor: KeleleColors.dark,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Refresh button
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => ref.invalidate(creatorsStreamProvider),
                          tooltip: 'Refresh',
                          style: IconButton.styleFrom(
                            backgroundColor: KeleleColors.grayLight,
                            foregroundColor: KeleleColors.dark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // View toggle
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: KeleleColors.grayBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            _ViewToggle(
                              label: 'Projects',
                              active: view == DirectoryView.projects,
                              onTap: () => ref
                                  .read(directoryViewProvider.notifier)
                                  .state = DirectoryView.projects,
                              isLeft: true,
                            ),
                            _ViewToggle(
                              label: 'People',
                              active: view == DirectoryView.people,
                              onTap: () => ref
                                  .read(directoryViewProvider.notifier)
                                  .state = DirectoryView.people,
                              isLeft: false,
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  // Active filter chips
                  if (hasActiveFilters)
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list,
                              size: 16, color: KeleleColors.grayMid),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (selectedSkill != null)
                                    _ActiveFilter(
                                      label: selectedSkill,
                                      onRemove: () => ref
                                          .read(
                                              selectedSkillProvider.notifier)
                                          .state = null,
                                    ),
                                  if (selectedLocation != null) ...[
                                    if (selectedSkill != null)
                                      const SizedBox(width: 8),
                                    _ActiveFilter(
                                      label: selectedLocation,
                                      onRemove: () => ref
                                          .read(selectedLocationProvider
                                              .notifier)
                                          .state = null,
                                    ),
                                  ],
                                  if (selectedLevel != null) ...[
                                    const SizedBox(width: 8),
                                    _ActiveFilter(
                                      label: selectedLevel == 3
                                          ? 'Expert'
                                          : selectedLevel == 2
                                              ? 'Skilled'
                                              : 'Emerging',
                                      onRemove: () => ref
                                          .read(
                                              selectedLevelProvider.notifier)
                                          .state = null,
                                    ),
                                  ],
                                  if (selectedPrice != null) ...[
                                    const SizedBox(width: 8),
                                    _ActiveFilter(
                                      label: selectedPrice == PriceRange.budget
                                          ? 'Budget'
                                          : selectedPrice == PriceRange.mid
                                              ? 'Mid-range'
                                              : 'Premium',
                                      onRemove: () => ref
                                          .read(
                                              selectedPriceProvider.notifier)
                                          .state = null,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              ref.read(selectedSkillProvider.notifier).state =
                                  null;
                              ref
                                  .read(selectedLocationProvider.notifier)
                                  .state = null;
                              ref.read(selectedLevelProvider.notifier).state =
                                  null;
                              ref.read(selectedPriceProvider.notifier).state =
                                  null;
                            },
                            child: Text('Clear all',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: KeleleColors.pink,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 1),
                ],
              ),
            ),

            // ─── CONTENT ───────────────────────
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: view == DirectoryView.projects
                      ? _ProjectsView(
                          projects: filteredProjects,
                          onOpenLightbox: _openLightbox,
                          isLoading: isLoading,
                        )
                      : const _PeopleView(),
                ),
              ),
            ),
          ],
        ),

        // Project lightbox
        if (_lightboxData != null)
          ProjectLightbox(
            projectId: _lightboxData!.projectId,
            creatorId: _lightboxData!.creatorId,
            onClose: _closeLightbox,
            onViewCreator: (id) {
              _closeLightbox();
              context.push('/profile/$id');
            },
          ),
      ],
    );
  }
}

// ─── PROJECTS GRID ──────────────────────────────
class _ProjectsView extends StatelessWidget {
  final List<({PortfolioItem project, Creator creator})> projects;
  final void Function(String projectId, String creatorId) onOpenLightbox;
  final bool isLoading;

  const _ProjectsView(
      {required this.projects, required this.onOpenLightbox, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Text('No projects match your search',
                style: TextStyle(color: KeleleColors.grayMid)),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          sliver: SliverToBoxAdapter(
            child: Text(
                '${projects.length} project${projects.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 14, color: KeleleColors.grayMid)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final entry = projects[i];
                return ProjectCard(
                  project: entry.project,
                  creator: entry.creator,
                  onTap: () =>
                      onOpenLightbox(entry.project.id, entry.creator.id),
                );
              },
              childCount: projects.length,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 340,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── PEOPLE GRID (with shuffle animation) ───────
class _PeopleView extends ConsumerStatefulWidget {
  const _PeopleView();

  @override
  ConsumerState<_PeopleView> createState() => _PeopleViewState();
}

class _PeopleViewState extends ConsumerState<_PeopleView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shuffleAnim;
  List<double> _randomAngles = [];
  int _lastSeed = 0;

  @override
  void initState() {
    super.initState();
    _shuffleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _shuffleAnim.dispose();
    super.dispose();
  }

  void _triggerShuffle(int creatorCount) {
    // Generate random rotation angles for each card
    final rng = Random();
    _randomAngles = List.generate(
      creatorCount,
      (_) => (rng.nextDouble() - 0.5) * 0.15, // ±~4.3 degrees in radians
    );
    _shuffleAnim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final creators = ref.watch(shuffledCreatorsProvider);
    final seed = ref.watch(shuffleSeedProvider);

    // Trigger animation when seed changes
    if (seed != _lastSeed && seed != 0) {
      _lastSeed = seed;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _triggerShuffle(creators.length);
      });
    }

    if (creators.isEmpty) {
      final loading = !useMockData && ref.watch(creatorsStreamProvider).isLoading;
      return Center(
        child: loading
            ? const CircularProgressIndicator()
            : Text('No creators match your search',
                style: TextStyle(color: KeleleColors.grayMid)),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          sliver: SliverToBoxAdapter(
            child: Text(
                '${creators.length} creator${creators.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 14, color: KeleleColors.grayMid)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                return AnimatedBuilder(
                  animation: _shuffleAnim,
                  builder: (context, child) {
                    final t = _shuffleAnim.value;
                    // Phase 1 (0→0.4): scale down, rotate, fade
                    // Phase 2 (0.4→1.0): bounce back
                    double scale;
                    double rotation;
                    double opacity;

                    if (t <= 0.4) {
                      // Scatter phase
                      final p = t / 0.4;
                      scale = 1.0 - (0.15 * Curves.easeOut.transform(p));
                      rotation = i < _randomAngles.length
                          ? _randomAngles[i] * Curves.easeOut.transform(p)
                          : 0;
                      opacity = 1.0 - (0.4 * p);
                    } else {
                      // Bounce-back phase
                      final p = (t - 0.4) / 0.6;
                      final bounce = Curves.bounceOut.transform(p);
                      scale = 0.85 + (0.15 * bounce);
                      rotation = i < _randomAngles.length
                          ? _randomAngles[i] * (1.0 - bounce)
                          : 0;
                      opacity = 0.6 + (0.4 * bounce);
                    }

                    return Opacity(
                      opacity: _shuffleAnim.isAnimating ? opacity : 1.0,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: _shuffleAnim.isAnimating
                            ? (Matrix4.identity()
                              ..scaleByDouble(scale, scale, 1.0, 1.0)
                              ..rotateZ(rotation))
                            : Matrix4.identity(),
                        child: child,
                      ),
                    );
                  },
                  child: PeopleCard(
                    key: ValueKey(creators[i].id),
                    creator: creators[i],
                    onTap: () => context.push('/profile/${creators[i].id}'),
                  ),
                );
              },
              childCount: creators.length,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.82,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── VIEW TOGGLE BUTTON ─────────────────────────
class _ViewToggle extends StatelessWidget {
  final String label;
  final bool active, isLeft;
  final VoidCallback onTap;

  const _ViewToggle(
      {required this.label,
      required this.active,
      required this.onTap,
      required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? KeleleColors.dark : Colors.white,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(7) : Radius.zero,
            right: !isLeft ? const Radius.circular(7) : Radius.zero,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: active ? Colors.white : KeleleColors.grayMid,
            )),
      ),
    );
  }
}

// ─── ACTIVE FILTER CHIP ─────────────────────────
class _ActiveFilter extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveFilter({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: KeleleColors.pinkGlow,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: KeleleColors.pink)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child:
                const Icon(Icons.close, size: 14, color: KeleleColors.pink),
          ),
        ],
      ),
    );
  }
}
