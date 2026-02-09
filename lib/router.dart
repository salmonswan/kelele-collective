import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/app_shell.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/onboarding/creator_application.dart';

/// Notifier that fires when auth state changes, used by GoRouter.refreshListenable.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final loggedIn = ref.read(authProvider) != null;
      final isAuthRoute =
          state.uri.path == '/login' || state.uri.path == '/signup';
      final isApply = state.uri.path == '/apply';

      if (!loggedIn && !isAuthRoute && !isApply) return '/login';
      if (loggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (ctx, state) => const AuthScreen(isLogin: true),
      ),
      GoRoute(
        path: '/signup',
        builder: (ctx, state) => const AuthScreen(isLogin: false),
      ),
      GoRoute(
        path: '/apply',
        builder: (ctx, state) => CreatorApplicationScreen(
          onComplete: () => GoRouter.of(ctx).go('/login'),
        ),
      ),
      GoRoute(
        path: '/',
        builder: (ctx, state) => const AppShell(),
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (ctx, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ProfileScreen(creatorId: id);
        },
      ),
    ],
  );
});
