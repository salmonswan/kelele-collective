import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/creator.dart';
import '../../providers/creator_provider.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import 'widgets/project_card.dart';
import 'widgets/people_card.dart';
import 'widgets/profile_panel.dart';
import 'widgets/project_lightbox.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  int? _panelCreatorId;
  ({int projectId, int creatorId})? _lightboxData;

  void _openPanel(int creatorId) => setState(() => _panelCreatorId = creatorId);
  void _closePanel() => setState(() => _panelCreatorId = null);

  void _openLightbox(int projectId, int creatorId) =>
      setState(() => _lightboxData = (projectId: projectId, creatorId: creatorId));
  void _closeLightbox() => setState(() => _lightboxData = null);

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(directoryViewProvider);
    final query = ref.watch(searchQueryProvider);
    final selectedSkill = ref.watch(selectedSkillProvider);
    final filteredProjects = ref.watch(filteredProjectsProvider);
    final filteredCreators = ref.watch(filteredCreatorsProvider);
    final creators = ref.watch(creatorsProvider);

    final panelCreator = _panelCreatorId != null
        ? creators.where((c) => c.id == _panelCreatorId).firstOrNull
        : null;

    return Stack(
      children: [
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
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: KeleleColors.grayLight,
                              border: Border.all(color: KeleleColors.grayBorder),
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
                        const SizedBox(width: 16),
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
                  // Skill pills
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _SkillPill(
                          label: 'All',
                          active: selectedSkill == null,
                          isPrimary: true,
                          onTap: () => ref
                              .read(selectedSkillProvider.notifier)
                              .state = null,
                        ),
                        ...skillsList.map((s) => _SkillPill(
                              label: s,
                              active: selectedSkill == s,
                              onTap: () => ref
                                  .read(selectedSkillProvider.notifier)
                                  .state = selectedSkill == s ? null : s,
                            )),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),

            // ─── CONTENT ───────────────────────
            Expanded(
              child: view == DirectoryView.projects
                  ? _ProjectsView(
                      projects: filteredProjects,
                      onOpenLightbox: _openLightbox,
                    )
                  : _PeopleView(
                      creators: filteredCreators,
                      onOpenPanel: _openPanel,
                    ),
            ),
          ],
        ),

        // Profile slide panel
        if (panelCreator != null)
          ProfilePanel(
            creator: panelCreator,
            onClose: _closePanel,
            onViewFull: () {
              _closePanel();
              // Navigate via GoRouter
            },
          ),

        // Project lightbox
        if (_lightboxData != null)
          ProjectLightbox(
            projectId: _lightboxData!.projectId,
            creatorId: _lightboxData!.creatorId,
            onClose: _closeLightbox,
            onViewCreator: (id) {
              _closeLightbox();
              _openPanel(id);
            },
          ),
      ],
    );
  }
}

// ─── PROJECTS GRID ──────────────────────────────
class _ProjectsView extends StatelessWidget {
  final List<({PortfolioItem project, Creator creator})> projects;
  final void Function(int projectId, int creatorId) onOpenLightbox;

  const _ProjectsView({required this.projects, required this.onOpenLightbox});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Center(
        child: Text('No projects match your search',
            style: TextStyle(color: KeleleColors.grayMid)),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          sliver: SliverToBoxAdapter(
            child: Text('${projects.length} project${projects.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 12, color: KeleleColors.grayMid)),
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
                  onTap: () => onOpenLightbox(entry.project.id, entry.creator.id),
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

// ─── PEOPLE GRID ────────────────────────────────
class _PeopleView extends StatelessWidget {
  final List<Creator> creators;
  final void Function(int creatorId) onOpenPanel;

  const _PeopleView({required this.creators, required this.onOpenPanel});

  @override
  Widget build(BuildContext context) {
    if (creators.isEmpty) {
      return Center(
        child: Text('No creators match your search',
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
                style: TextStyle(fontSize: 12, color: KeleleColors.grayMid)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => PeopleCard(
                creator: creators[i],
                onTap: () => onOpenPanel(creators[i].id),
              ),
              childCount: creators.length,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.68,
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

// ─── SKILL PILL ─────────────────────────────────
class _SkillPill extends StatelessWidget {
  final String label;
  final bool active;
  final bool isPrimary;
  final VoidCallback onTap;

  const _SkillPill(
      {required this.label,
      required this.active,
      required this.onTap,
      this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Text(label),
          backgroundColor: active
              ? (isPrimary ? KeleleColors.pink : KeleleColors.dark)
              : KeleleColors.grayLight,
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : KeleleColors.dark,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
