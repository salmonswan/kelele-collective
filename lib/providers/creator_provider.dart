import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/creator.dart';
import '../data/mock_data.dart';

class CreatorNotifier extends StateNotifier<List<Creator>> {
  CreatorNotifier() : super(mockCreators);

  void addCreator(Creator creator) {
    state = [...state, creator];
  }

  void updateCreator(Creator updated) {
    state = [
      for (final c in state)
        if (c.id == updated.id) updated else c,
    ];
  }

  void updateStatus(int id, CreatorStatus status,
      {String notes = '', String reviewer = '', String reapplyAfter = ''}) {
    state = [
      for (final c in state)
        if (c.id == id)
          c.copyWith(
            status: status,
            reviewNotes: notes,
            reviewedBy: reviewer,
            reviewedAt: DateTime.now().toIso8601String().substring(0, 10),
            reapplyAfter: reapplyAfter,
            isPublic: status == CreatorStatus.verified,
          )
        else
          c,
    ];
  }

  void togglePublic(int id) {
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(isPublic: !c.isPublic) else c,
    ];
  }

  int get nextId => state.isEmpty ? 1 : state.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
}

final creatorsProvider =
    StateNotifierProvider<CreatorNotifier, List<Creator>>((ref) {
  return CreatorNotifier();
});

// Derived: verified AND public creators only
final verifiedCreatorsProvider = Provider<List<Creator>>((ref) {
  return ref
      .watch(creatorsProvider)
      .where((c) => c.status == CreatorStatus.verified && c.isPublic)
      .toList();
});

// Derived: all projects from verified creators
final allProjectsProvider = Provider<List<({PortfolioItem project, Creator creator})>>((ref) {
  final verified = ref.watch(verifiedCreatorsProvider);
  return [
    for (final c in verified)
      for (final p in c.portfolio) (project: p, creator: c),
  ];
});

// Bookmarks
class BookmarksNotifier extends StateNotifier<Set<int>> {
  BookmarksNotifier() : super({});

  void toggle(int creatorId) {
    if (state.contains(creatorId)) {
      state = {...state}..remove(creatorId);
    } else {
      state = {...state, creatorId};
    }
  }

  void clear() => state = {};
}

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, Set<int>>((ref) {
  return BookmarksNotifier();
});

// Search & filter state
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedSkillProvider = StateProvider<String?>((ref) => null);
final directoryViewProvider = StateProvider<DirectoryView>((ref) => DirectoryView.projects);

enum DirectoryView { projects, people }

// Filtered projects
final filteredProjectsProvider =
    Provider<List<({PortfolioItem project, Creator creator})>>((ref) {
  final all = ref.watch(allProjectsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final skill = ref.watch(selectedSkillProvider);

  return all.where((entry) {
    final p = entry.project;
    final c = entry.creator;
    final matchQuery = query.isEmpty ||
        p.title.toLowerCase().contains(query) ||
        c.name.toLowerCase().contains(query) ||
        p.skill.toLowerCase().contains(query);
    final matchSkill =
        skill == null || p.skill == skill || c.skills.contains(skill);
    return matchQuery && matchSkill;
  }).toList();
});

// Filtered creators
final filteredCreatorsProvider = Provider<List<Creator>>((ref) {
  final verified = ref.watch(verifiedCreatorsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final skill = ref.watch(selectedSkillProvider);

  return verified.where((c) {
    final matchQuery = query.isEmpty ||
        c.name.toLowerCase().contains(query) ||
        c.primarySkill.toLowerCase().contains(query) ||
        c.bio.toLowerCase().contains(query);
    final matchSkill = skill == null || c.skills.contains(skill);
    return matchQuery && matchSkill;
  }).toList();
});
