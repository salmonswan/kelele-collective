# Kelele Collective — Project Rules

## Stack
- **Framework:** Flutter web (Dart)
- **State:** Riverpod 2.x (StreamProvider, StateProvider, Provider)
- **Routing:** GoRouter with auth redirect via `refreshListenable`
- **Backend:** Firebase (Auth, Firestore, Storage) — project `kelele-genius`
- **Hosting:** Docker (nginx:alpine) on Contabo at `genius.kelelecollective.org`
- **Fonts:** Space Grotesk (headlines), DM Sans (body) via google_fonts

## Critical Patterns

### Riverpod AsyncValue — NEVER use `.valueOrNull` for auth state
`.valueOrNull` preserves the previous value during loading/refreshing states. This caused a critical logout bug where the user appeared permanently logged in. Always use explicit `.when()`:
```dart
// WRONG — stale value during loading
return ref.watch(authProvider).valueOrNull;

// RIGHT — null during loading
return ref.watch(authProvider).when(
  data: (user) => user,
  loading: () => null,
  error: (_, __) => null,
);
```
`.valueOrNull` IS safe for data-only providers like `creatorsProvider` where stale = empty list.

### Router Auth — `_AuthChangeNotifier` must store subscriptions
`ref.listen()` returns a `ProviderSubscription` that MUST be stored as a field. Without storage, Dart GC collects the subscription and auth state changes never trigger router redirects.

### Logout — let the router handle navigation
Do NOT call `context.go('/login')` in logout handlers. Just `await signOut()` and let the `_AuthChangeNotifier` → router redirect handle navigation. Manual navigation races with the redirect.

### Firebase mode (`useMockData = false`)
- All Firestore writes must be `await`ed
- All write operations need try/catch with user-visible error feedback (snackbar)
- After `await` in StatefulWidgets, check `mounted` before `setState` or `context`
- `Stream.empty()` in a StreamProvider means it NEVER settles — use `Stream.value(null)` for "no data"

## Architecture

### Data Flow
```
Firebase Auth → firebaseAuthStateProvider (StreamProvider<User?>)
  → authProvider (StreamProvider<AppUser?>)
    → currentUserProvider (Provider<AppUser?>) — uses .when(), not .valueOrNull
      → _AuthChangeNotifier → GoRouter redirect

Firestore creators → creatorsStreamProvider (StreamProvider<List<Creator>>)
  → creatorsProvider → verifiedCreatorsProvider → filtered/shuffled providers
```

### Creator Model (v2 skill system)
- `mainSkill` (SkillEntry: discipline + specification + years) — primary field
- `sideSkills` (List<SkillEntry>) — secondary skills, max 3
- `primarySkill`, `skills`, `level` — DEPRECATED, kept for Firestore backward compat only
- Use `Creator.experienceToLevel(years)` (public static) to derive level from years
- Never read deprecated fields in UI — always use `mainSkill.discipline`, `sideSkills`

### Guest Mode
Firebase guest mode uses `isGuestProvider` (StateProvider<bool>). When true, `currentUserProvider` returns a synthetic guest AppUser. Clear on logout.

## Deployment
- Server: `root@144.91.109.129` (Contabo)
- App path: `/root/kelele_app`
- Docker port: `8008:80`
- Build: `docker build --no-cache -t kelele_app_kelele-web:latest .`
- Restart: `docker stop kelele-web && docker rm kelele-web && docker run -d --name kelele-web -p 8008:80 --restart unless-stopped kelele_app_kelele-web:latest`
- SSH to GitHub uses port 443 (`~/.ssh/config`)
- Remote: `git@github.com:salmonswan/kelele-collective.git`

## Commit Rules
- No Claude/AI/LLM references in commit messages or code
- No Co-Authored-By lines
- Keep commit trail (don't squash debugging history)

## File Structure
```
lib/
  config.dart              — useMockData flag
  firebase_options.dart    — Firebase web SDK config
  main.dart                — entry point + one-time seed
  router.dart              — GoRouter + auth redirect
  models/                  — Creator, AppUser
  providers/               — auth_provider, creator_provider
  services/                — auth_service, creator_service, seed_service
  screens/                 — auth, app_shell, directory, profile, admin, onboarding, dashboards
  widgets/                 — status_badge
  theme/                   — app_theme (KeleleColors, KeleleTheme)
  data/                    — mock_data (10 creators, discipline specs, software list)
```
