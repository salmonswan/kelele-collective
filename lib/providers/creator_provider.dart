import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config.dart';
import '../data/mock_data.dart';
import '../models/creator.dart';
import '../services/creator_service.dart';

final creatorServiceProvider =
    Provider<CreatorService>((ref) => CreatorService());

/// Core stream of all creators from Firestore.
final creatorsStreamProvider = StreamProvider<List<Creator>>((ref) {
  if (useMockData) return Stream.value(mockCreators);
  final service = ref.watch(creatorServiceProvider);
  return service.creatorsStream().map((snapshot) => snapshot.docs
      .map((doc) =>
          Creator.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
      .toList());
});

/// Synchronous convenience provider — returns List<Creator>.
final creatorsProvider = Provider<List<Creator>>((ref) {
  if (useMockData) return mockCreators;
  return ref.watch(creatorsStreamProvider).valueOrNull ?? [];
});

/// Derived: verified AND public creators only.
final verifiedCreatorsProvider = Provider<List<Creator>>((ref) {
  return ref
      .watch(creatorsProvider)
      .where((c) => (c.status == CreatorStatus.verified || c.status == CreatorStatus.verifiedEmerging) && c.isPublic)
      .toList();
});

/// Derived: all projects from verified creators.
final allProjectsProvider =
    Provider<List<({PortfolioItem project, Creator creator})>>((ref) {
  final verified = ref.watch(verifiedCreatorsProvider);
  return [
    for (final c in verified)
      for (final p in c.portfolio) (project: p, creator: c),
  ];
});

// Search & filter state (local UI state — no Firebase needed)
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedSkillProvider = StateProvider<String?>((ref) => null);
final selectedLocationProvider = StateProvider<String?>((ref) => null);
final selectedLevelProvider = StateProvider<int?>((ref) => null);
final selectedPriceProvider = StateProvider<PriceRange?>((ref) => null);
final directoryViewProvider =
    StateProvider<DirectoryView>((ref) => DirectoryView.people);

enum DirectoryView { projects, people }

/// Distinct locations from verified creators.
final locationsProvider = Provider<List<String>>((ref) {
  final creators = ref.watch(verifiedCreatorsProvider);
  final locs = creators.map((c) => c.location).toSet().toList()..sort();
  return locs;
});

/// Filtered projects.
final filteredProjectsProvider =
    Provider<List<({PortfolioItem project, Creator creator})>>((ref) {
  final all = ref.watch(allProjectsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final skill = ref.watch(selectedSkillProvider);
  final location = ref.watch(selectedLocationProvider);
  final level = ref.watch(selectedLevelProvider);
  final price = ref.watch(selectedPriceProvider);

  return all.where((entry) {
    final p = entry.project;
    final c = entry.creator;
    final matchQuery = query.isEmpty ||
        p.title.toLowerCase().contains(query) ||
        c.name.toLowerCase().contains(query) ||
        p.skill.toLowerCase().contains(query);
    final matchSkill =
        skill == null || p.skill == skill || c.mainSkill.discipline == skill || c.sideSkills.any((s) => s.discipline == skill);
    final matchLocation = location == null || c.location == location;
    final matchLevel = level == null || Creator.experienceToLevel(c.mainSkill.yearsOfExperience) == level;
    final matchPrice = price == null || c.priceRange == price;
    return matchQuery && matchSkill && matchLocation && matchLevel && matchPrice;
  }).toList();
});

// ─── Shuffle state ───────────────────────────────
final shuffleSeedProvider = StateProvider<int>((ref) => 0);

/// Shuffled creators — uses seed to randomize order. Seed 0 = original order.
final shuffledCreatorsProvider = Provider<List<Creator>>((ref) {
  final creators = ref.watch(filteredCreatorsProvider);
  final seed = ref.watch(shuffleSeedProvider);
  if (seed == 0) return creators;
  final list = List<Creator>.from(creators);
  list.shuffle(Random(seed));
  return list;
});

// ─── Guide wizard state ─────────────────────────
final showGuideProvider = StateProvider<bool>((ref) => true);

/// Filtered creators.
final filteredCreatorsProvider = Provider<List<Creator>>((ref) {
  final verified = ref.watch(verifiedCreatorsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final skill = ref.watch(selectedSkillProvider);
  final location = ref.watch(selectedLocationProvider);
  final level = ref.watch(selectedLevelProvider);
  final price = ref.watch(selectedPriceProvider);

  return verified.where((c) {
    final matchQuery = query.isEmpty ||
        c.name.toLowerCase().contains(query) ||
        c.mainSkill.discipline.toLowerCase().contains(query) ||
        c.bio.toLowerCase().contains(query);
    final matchSkill = skill == null || c.mainSkill.discipline == skill || c.sideSkills.any((s) => s.discipline == skill);
    final matchLocation = location == null || c.location == location;
    final matchLevel = level == null || Creator.experienceToLevel(c.mainSkill.yearsOfExperience) == level;
    final matchPrice = price == null || c.priceRange == price;
    return matchQuery && matchSkill && matchLocation && matchLevel && matchPrice;
  }).toList();
});
