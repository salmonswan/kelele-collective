import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../config.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// ─── Service ────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ─── Mock auth (in-memory) ──────────────────────
class MockAuthNotifier extends StateNotifier<AppUser?> {
  MockAuthNotifier() : super(null);

  void login(String name, String email, UserRole role) {
    state = AppUser(
      uid: 'mock-${email.hashCode}',
      name: name,
      email: email,
      role: role,
      initials: buildInitials(name),
    );
  }

  void loginAsGuest() {
    state = const AppUser(
      uid: 'guest',
      name: 'Guest',
      email: '',
      role: UserRole.finder,
      initials: 'G',
      isGuest: true,
    );
  }

  void logout() => state = null;
}

final mockAuthProvider =
    StateNotifierProvider<MockAuthNotifier, AppUser?>((ref) => MockAuthNotifier());

final _mockBookmarksProvider = StateProvider<Set<String>>((ref) => {});

// ─── Firebase auth streams ──────────────────────
final firebaseAuthStateProvider = StreamProvider<fb.User?>((ref) {
  if (useMockData) return const Stream.empty();
  return ref.watch(authServiceProvider).authStateChanges;
});

final authProvider = StreamProvider<AppUser?>((ref) {
  if (useMockData) return const Stream.empty();
  final fbAsync = ref.watch(firebaseAuthStateProvider);
  return fbAsync.when(
    data: (fbUser) {
      if (fbUser == null) return Stream.value(null);
      return ref
          .watch(authServiceProvider)
          .userDocStream(fbUser.uid)
          .map((snap) {
        if (!snap.exists) return null;
        return AppUser.fromFirestore(
            fbUser.uid, snap.data()! as Map<String, dynamic>);
      });
    },
    loading: () => const Stream.empty(),
    error: (_, __) => Stream.value(null),
  );
});

// ─── Convenience providers (work in both modes) ─
final currentUserProvider = Provider<AppUser?>((ref) {
  if (useMockData) return ref.watch(mockAuthProvider);
  return ref.watch(authProvider).valueOrNull;
});

final bookmarksProvider = Provider<Set<String>>((ref) {
  if (useMockData) return ref.watch(_mockBookmarksProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return user.bookmarks.toSet();
});

// ─── Toggle bookmark ────────────────────────────
Future<void> toggleBookmark(WidgetRef ref, String creatorId) async {
  if (useMockData) {
    final current = ref.read(_mockBookmarksProvider);
    if (current.contains(creatorId)) {
      ref.read(_mockBookmarksProvider.notifier).state =
          {...current}..remove(creatorId);
    } else {
      ref.read(_mockBookmarksProvider.notifier).state =
          {...current, creatorId};
    }
    return;
  }

  final user = ref.read(currentUserProvider);
  if (user == null) return;
  final docRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);
  if (user.bookmarks.contains(creatorId)) {
    await docRef.update({
      'bookmarks': FieldValue.arrayRemove([creatorId])
    });
  } else {
    await docRef.update({
      'bookmarks': FieldValue.arrayUnion([creatorId])
    });
  }
}

// ─── Helpers ────────────────────────────────────
String buildInitials(String name) {
  final parts = name.split(' ').where((w) => w.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  return parts.map((w) => w[0]).take(2).join().toUpperCase();
}
