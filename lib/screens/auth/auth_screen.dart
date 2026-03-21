import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config.dart';
import '../../data/mock_data.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

// ─── Background card data ───────────────────────
class _BgCover {
  final String imageUrl;
  final LinearGradient gradient;
  const _BgCover({required this.imageUrl, required this.gradient});
}

class _BgCard {
  final String creatorName;
  final String profilePhotoUrl;
  final String primarySkill;
  final String location;
  final List<_BgCover> covers; // up to 3
  const _BgCard({
    required this.creatorName,
    required this.profilePhotoUrl,
    required this.primarySkill,
    required this.location,
    required this.covers,
  });
}

const _defaultGradients = [
  LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
  LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
  LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
];

// ─── Mock test accounts ──────────────────────────
const _mockAccounts = [
  {'name': 'Tobi Fluck', 'email': 'tobi@kelele.com', 'password': 'admin123', 'role': 'admin'},
  {'name': 'Amara Nakato', 'email': 'amara@kelele.com', 'password': 'creative123', 'role': 'creative'},
  {'name': 'Daniel Okello', 'email': 'daniel@kelele.com', 'password': 'finder123', 'role': 'finder'},
];

enum _View { landing, finderAuth, creatorApply }

class AuthScreen extends ConsumerStatefulWidget {
  final bool isLogin;
  const AuthScreen({super.key, this.isLogin = true});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  _View _view = _View.landing;
  late bool _isLogin;

  // Finder auth form
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _nameC = TextEditingController();
  bool _showPass = false;
  bool _loading = false;
  String? _error;

  // Creator apply form
  final _creatorNameC = TextEditingController();
  final _creatorEmailC = TextEditingController();
  final _creatorSkillsC = TextEditingController();
  final _creatorSummaryC = TextEditingController();
  bool _creatorSubmitted = false;

  // Background
  late AnimationController _bgAnim;
  List<List<_BgCard>> _bgColumns = [];
  int _lastColCount = 0;
  static const _cardHeight = 280.0;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    )..repeat();
  }

  void _buildBgData(int colCount) {
    final allCards = <_BgCard>[];
    for (final c in mockCreators) {
      final covers = <_BgCover>[];
      for (int i = 0; i < 3; i++) {
        if (i < c.portfolio.length) {
          covers.add(_BgCover(
            imageUrl: c.portfolio[i].coverImageUrl,
            gradient: c.portfolio[i].cover,
          ));
        } else {
          covers.add(_BgCover(
            imageUrl: '',
            gradient: _defaultGradients[i % _defaultGradients.length],
          ));
        }
      }
      allCards.add(_BgCard(
        creatorName: c.name,
        profilePhotoUrl: c.profilePhotoUrl,
        primarySkill: c.mainSkill.discipline,
        location: c.location,
        covers: covers,
      ));
    }
    allCards.shuffle(Random(42));
    _bgColumns = List.generate(colCount, (_) => <_BgCard>[]);
    for (int i = 0; i < allCards.length; i++) {
      _bgColumns[i % colCount].add(allCards[i]);
    }
    for (final col in _bgColumns) {
      final original = List<_BgCard>.of(col);
      while (col.length < 8) {
        col.addAll(original);
      }
    }
    _lastColCount = colCount;
  }

  @override
  void dispose() {
    _bgAnim.dispose();
    _emailC.dispose();
    _passC.dispose();
    _nameC.dispose();
    _creatorNameC.dispose();
    _creatorEmailC.dispose();
    _creatorSkillsC.dispose();
    _creatorSummaryC.dispose();
    super.dispose();
  }

  Future<void> _submitFinderAuth() async {
    final email = _emailC.text.trim();
    final password = _passC.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Fill in all fields');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be 6+ characters');
      return;
    }
    if (!_isLogin && _nameC.text.trim().isEmpty) {
      setState(() => _error = 'Enter your name');
      return;
    }

    setState(() { _loading = true; _error = null; });

    if (useMockData) {
      if (_isLogin) {
        final account = _mockAccounts.cast<Map<String, String>?>().firstWhere(
          (a) => a!['email'] == email,
          orElse: () => null,
        );
        if (account == null) {
          setState(() { _loading = false; _error = 'No mock account with that email'; });
          return;
        }
        final role = UserRole.values.firstWhere((r) => r.name == account['role']);
        ref.read(mockAuthProvider.notifier).login(account['name']!, email, role);
      } else {
        ref.read(mockAuthProvider.notifier).login(
            _nameC.text.trim(), email, UserRole.finder);
      }
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final authService = ref.read(authServiceProvider);
      if (_isLogin) {
        await authService.signIn(email, password);
      } else {
        final name = _nameC.text.trim();
        final cred = await authService.signUp(email, password);
        await authService.createUserDoc(cred.user!.uid, {
          'name': name,
          'email': email,
          'role': UserRole.finder.name,
          'initials': buildInitials(name),
          'bookmarks': <String>[],
        });
      }
    } on fb.FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Authentication failed');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final wide = screenW > 800;
    final colCount = screenW > 1200 ? 6 : screenW > 900 ? 5 : screenW > 600 ? 4 : 3;

    if (colCount != _lastColCount) _buildBgData(colCount);

    return Scaffold(
      body: Stack(
        children: [
          // ─── ANIMATED CARD WALL ──────────────
          _buildBackground(colCount),

          // ─── PINK OVERLAY ────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE8547C).withValues(alpha:0.45),
                  const Color(0xFFD63384).withValues(alpha:0.55),
                ],
              ),
            ),
          ),

          // ─── CENTERED CONTENT ─────────────────
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _view == _View.landing
                    ? _buildLandingCard(wide, screenW)
                    : _view == _View.finderAuth
                        ? _buildFinderCard(wide, screenW)
                        : _buildCreatorCard(wide, screenW),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ANIMATED BACKGROUND ──────────────────────
  Widget _buildBackground(int colCount) {
    return Row(
      children: List.generate(colCount, (i) {
        final cards = _bgColumns[i];
        final scrollUp = i.isEven;
        final setHeight = _cardHeight * cards.length;
        final phase = i * 0.12;

        return Expanded(
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _bgAnim,
              builder: (context, child) {
                final val = (_bgAnim.value + phase) % 1.0;
                final dy = scrollUp
                    ? -val * setHeight
                    : -setHeight + val * setHeight;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: child,
                );
              },
              child: Column(
                children: [
                  for (int r = 0; r < 3; r++)
                    for (final card in cards)
                      SizedBox(
                        height: _cardHeight,
                        child: _BgCardWidget(data: card),
                      ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── LANDING CARD ─────────────────────────────
  Widget _buildLandingCard(bool wide, double screenW) {
    return Container(
      key: const ValueKey('landing'),
      constraints: BoxConstraints(maxWidth: wide ? (screenW * 0.55).clamp(700, 1000) : double.infinity),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha:0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.3), blurRadius: 40),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/noise-light1.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: wide ? 60 : 32, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/brand/k-empower-neg.png',
                  height: 200,
                  filterQuality: FilterQuality.medium,
                ),
                const SizedBox(height: 28),
                Text(
                  'Find Your Ugandan Genius.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: wide ? 32 : 24,
                    fontWeight: FontWeight.w700,
                    color: KeleleColors.pink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Just the right Multimedia Creative\nfor Your Project.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: wide ? 32 : 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Discovering vetted multimedia professionals in Uganda was never that easy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha:0.55),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),

                // CTA button
                SizedBox(
                  width: wide ? 400 : double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _view = _View.finderAuth),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KeleleColors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: Text('Explore Ugandan Talent',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 28),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LandingStat('50+', 'CREATORS'),
                    const SizedBox(width: 32),
                    _LandingStat('8', 'DISCIPLINES'),
                    const SizedBox(width: 32),
                    _LandingStat('100%', 'VETTED'),
                  ],
                ),
                const SizedBox(height: 24),

                // Creator link
                TextButton(
                  onPressed: () => setState(() => _view = _View.creatorApply),
                  style: TextButton.styleFrom(
                    foregroundColor: KeleleColors.pink,
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Creators this way'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── FINDER AUTH CARD (centered) ─────────────
  Widget _buildFinderCard(bool wide, double screenW) {
    return Container(
      key: const ValueKey('finder'),
      constraints: BoxConstraints(maxWidth: wide ? (screenW * 0.5).clamp(500, 800) : double.infinity),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.15), blurRadius: 30),
        ],
      ),
      padding: EdgeInsets.symmetric(
          horizontal: wide ? 48 : 28, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back + logo
          Row(
            children: [
              Material(
                color: KeleleColors.grayLight,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => setState(() => _view = _View.landing),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.arrow_back, size: 18),
                  ),
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/brand/k-empower-pos.png',
                height: 48,
                filterQuality: FilterQuality.medium,
              ),
              const Spacer(),
              const SizedBox(width: 34),
            ],
          ),
          const SizedBox(height: 28),

          // Title
          Text(
            _isLogin ? 'Log in, friend.' : 'Join the collective.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            _isLogin
                ? 'Welcome back! Enter your details.'
                : 'Create a free account to hire talent.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: KeleleColors.grayMid),
          ),
          const SizedBox(height: 24),

          // ─── Form body ───
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Guest mode
                  Material(
                    color: const Color(0xFFF0F7FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFFCCE0FF)),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (useMockData) {
                          ref.read(mockAuthProvider.notifier).loginAsGuest();
                        }
                        context.go('/');
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.visibility_outlined,
                                size: 20, color: Color(0xFF2B7CE9)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Browse as Guest',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2B7CE9))),
                                  Text('Explore profiles with limited details',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: KeleleColors.grayMid)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 12, color: Color(0xFF2B7CE9)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or sign in for full access',
                            style: TextStyle(
                                fontSize: 13, color: KeleleColors.grayMid)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Error
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        border: Border.all(color: const Color(0xFFFFD4D4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFFCC0000))),
                    ),

                  // Name (signup)
                  if (!_isLogin) ...[
                    _FieldLabel('Full Name'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameC,
                      decoration: const InputDecoration(hintText: 'Your name'),
                    ),
                    const SizedBox(height: 14),
                  ],

                  _FieldLabel('Email'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(hintText: 'you@example.com'),
                  ),
                  const SizedBox(height: 14),

                  _FieldLabel('Password'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passC,
                    obscureText: !_showPass,
                    onSubmitted: (_) => _submitFinderAuth(),
                    decoration: InputDecoration(
                      hintText: 'Min. 6 characters',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPass ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                          color: KeleleColors.grayMid,
                        ),
                        onPressed: () =>
                            setState(() => _showPass = !_showPass),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _loading ? null : _submitFinderAuth,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(_isLogin ? 'Sign In' : 'Create Account'),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? 'No account? ' : 'Have an account? ',
                        style:
                            TextStyle(fontSize: 13, color: KeleleColors.grayMid),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _isLogin = !_isLogin;
                          _error = null;
                        }),
                        style: TextButton.styleFrom(
                          foregroundColor: KeleleColors.pink,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        child: Text(_isLogin ? 'Sign up' : 'Sign in'),
                      ),
                    ],
                  ),

                  // Quick login (mock mode)
                  if (useMockData && _isLogin) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: KeleleColors.grayBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text('Quick Login',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Tap to sign in as a test user',
                              style: TextStyle(
                                  fontSize: 12, color: KeleleColors.grayMid)),
                          const SizedBox(height: 10),
                          ..._mockAccounts.map((a) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      final role = UserRole.values
                                          .firstWhere(
                                              (r) => r.name == a['role']);
                                      ref
                                          .read(mockAuthProvider.notifier)
                                          .login(
                                              a['name']!, a['email']!, role);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 14),
                                      side: BorderSide(
                                          color: KeleleColors.grayBorder),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor:
                                              a['role'] == 'admin'
                                                  ? KeleleColors.pink
                                                  : a['role'] == 'creative'
                                                      ? const Color(0xFF6C5CE7)
                                                      : const Color(0xFF00B894),
                                          child: Text(
                                            a['name']!
                                                .split(' ')
                                                .map((w) => w[0])
                                                .take(2)
                                                .join(),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(a['name']!,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              Text(
                                                '${a['role']![0].toUpperCase()}${a['role']!.substring(1)}',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        KeleleColors.grayMid),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 11,
                                            color: KeleleColors.grayMid),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CREATOR APPLICATION CARD (centered) ─────
  Widget _buildCreatorCard(bool wide, double screenW) {
    return Container(
      key: const ValueKey('creator'),
      constraints: BoxConstraints(maxWidth: wide ? (screenW * 0.5).clamp(500, 800) : double.infinity),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.15), blurRadius: 30),
        ],
      ),
      padding: EdgeInsets.symmetric(
          horizontal: wide ? 48 : 28, vertical: 36),
      child: _creatorSubmitted
          ? _buildCreatorSuccess()
          : _buildCreatorForm(),
    );
  }

  Widget _buildCreatorForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Back + logo
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _view = _View.landing),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: KeleleColors.grayLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, size: 18),
              ),
            ),
            const Spacer(),
            Image.asset(
              'assets/brand/k-empower-pos.png',
              height: 48,
              filterQuality: FilterQuality.medium,
            ),
            const Spacer(),
            const SizedBox(width: 34),
          ],
        ),
        const SizedBox(height: 28),

        Text('Join as a Creator',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          'Kelele is invite-only. Share your details and we\'ll review your application.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13, color: KeleleColors.grayMid, height: 1.5),
        ),
        const SizedBox(height: 16),

        // ─── Form body ───
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: KeleleColors.pinkGlow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_outlined,
                          size: 18, color: KeleleColors.pink),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Every creator is personally vetted for quality.',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: KeleleColors.pinkDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _FieldLabel('Full Name'),
                const SizedBox(height: 6),
                TextField(
                  controller: _creatorNameC,
                  decoration: const InputDecoration(hintText: 'Your full name'),
                ),
                const SizedBox(height: 14),

                _FieldLabel('Email'),
                const SizedBox(height: 6),
                TextField(
                  controller: _creatorEmailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'you@example.com'),
                ),
                const SizedBox(height: 14),

                _FieldLabel('Skills / Disciplines'),
                const SizedBox(height: 6),
                TextField(
                  controller: _creatorSkillsC,
                  decoration: const InputDecoration(
                      hintText: 'e.g. Photography, Motion Design'),
                ),
                const SizedBox(height: 14),

                _FieldLabel('Tell us about your work'),
                const SizedBox(height: 6),
                TextField(
                  controller: _creatorSummaryC,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'Brief summary of your experience, links to your portfolio...',
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    if (_creatorNameC.text.trim().isEmpty ||
                        _creatorEmailC.text.trim().isEmpty ||
                        _creatorSkillsC.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill in all required fields')),
                      );
                      return;
                    }
                    setState(() => _creatorSubmitted = true);
                  },
                  child: const Text('Submit Application'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or',
                          style: TextStyle(
                              fontSize: 13, color: KeleleColors.grayMid)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/apply'),
                    icon: const Icon(Icons.assignment_outlined, size: 18),
                    label: const Text('Start Full Application'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KeleleColors.pink,
                      side: BorderSide(color: KeleleColors.pink),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Looking to hire? ',
                        style:
                            TextStyle(fontSize: 13, color: KeleleColors.grayMid)),
                    TextButton(
                      onPressed: () => setState(() => _view = _View.finderAuth),
                      style: TextButton.styleFrom(
                        foregroundColor: KeleleColors.pink,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Sign in as Finder'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: KeleleColors.pinkGlow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.check_circle,
              size: 48, color: KeleleColors.pink),
        ),
        const SizedBox(height: 24),
        Text('Application Sent!',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text(
          'Thanks, ${_creatorNameC.text.trim().split(' ').first}! We\'ll review your application and get back to you at ${_creatorEmailC.text.trim()}.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14, color: KeleleColors.grayMid, height: 1.6),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => setState(() {
            _view = _View.landing;
            _creatorSubmitted = false;
            _creatorNameC.clear();
            _creatorEmailC.clear();
            _creatorSkillsC.clear();
            _creatorSummaryC.clear();
          }),
          child: const Text('Back to Home'),
        ),
      ],
    );
  }
}

// ─── Background card widget ─────────────────────
class _BgCardWidget extends StatelessWidget {
  final _BgCard data;
  const _BgCardWidget({required this.data});

  Widget _coverTile(_BgCover cover) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(decoration: BoxDecoration(gradient: cover.gradient)),
        if (cover.imageUrl.isNotEmpty)
          cover.imageUrl.startsWith('assets/')
              ? Image.asset(cover.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink())
              : Image.network(cover.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ─── IMAGE COLLAGE ─────────────────
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    width: double.infinity,
                    child: _coverTile(data.covers[0]),
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(child: _coverTile(data.covers[1])),
                      const SizedBox(width: 2),
                      Expanded(child: _coverTile(data.covers[2])),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── PROFILE CIRCLE + TEXT ─────────
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 22, 8, 8),
                child: Column(
                  children: [
                    Text(
                      data.creatorName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            data.primarySkill,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: KeleleColors.pink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Icon(Icons.circle, size: 2, color: KeleleColors.grayMid),
                        ),
                        Flexible(
                          child: Text(
                            data.location,
                            style: TextStyle(fontSize: 10, color: KeleleColors.grayMid),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -18,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: KeleleColors.grayLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: data.profilePhotoUrl.isNotEmpty
                      ? (data.profilePhotoUrl.startsWith('assets/')
                          ? Image.asset(data.profilePhotoUrl, fit: BoxFit.cover)
                          : Image.network(data.profilePhotoUrl, fit: BoxFit.cover))
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LandingStat extends StatelessWidget {
  final String value, label;
  const _LandingStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: KeleleColors.pink)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.white.withValues(alpha:0.4))),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: KeleleColors.grayMid)),
    );
  }
}
