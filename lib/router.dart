import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/app_shell.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/onboarding/creator_application.dart';

/// Notifier that fires when auth state changes, used by GoRouter.refreshListenable.
class _AuthChangeNotifier extends ChangeNotifier {
  late final ProviderSubscription _sub;

  _AuthChangeNotifier(Ref ref) {
    _sub = useMockData
        ? ref.listen(mockAuthProvider, (_, __) => notifyListeners())
        : ref.listen(authProvider, (_, __) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

/// Fade transition — used for auth <-> home switches.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Slide-up transition — used for detail / overlay pages.
CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOut));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: animation.drive(tween), child: child),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final loggedIn = ref.read(currentUserProvider) != null;
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
        pageBuilder: (ctx, state) =>
            _fadePage(state, const AuthScreen(isLogin: true)),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (ctx, state) =>
            _fadePage(state, const AuthScreen(isLogin: false)),
      ),
      GoRoute(
        path: '/apply',
        pageBuilder: (ctx, state) => _slidePage(
          state,
          CreatorApplicationScreen(
            onComplete: () => GoRouter.of(ctx).go('/login'),
          ),
        ),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (ctx, state) => _fadePage(state, const AppShell()),
      ),
      GoRoute(
        path: '/profile/:id',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            opaque: false,
            child: ProfileScreen(creatorId: id),
            transitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
    ],
  );
});
