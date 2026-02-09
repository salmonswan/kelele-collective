import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class _HeroSlide {
  final String label, headline, sub;
  final LinearGradient bg;
  final Color accent;
  const _HeroSlide(this.label, this.headline, this.sub, this.bg, this.accent);
}

final _slides = [
  _HeroSlide(
    'Find Your Genius',
    'Find your\ngenius.',
    'Discover vetted Ugandan multimedia professionals. Every creator verified for quality.',
    const LinearGradient(colors: [Color(0xFF0C0C20), Color(0xFF1A1A35)]),
    KeleleColors.pink,
  ),
  _HeroSlide(
    'How It Works',
    'Every creator,\npersonally vetted.',
    'Apply → Review → Verify → Connect.\nNo guesswork — just verified talent.',
    const LinearGradient(colors: [Color(0xFFC40041), Color(0xFFFF1A66)]),
    KeleleColors.yellow,
  ),
  _HeroSlide(
    'The Talent',
    '8 disciplines.\n50+ creators.',
    'Photography, Videography, Motion Design, Graphic Design, Sound Design, Illustration, 3D Design, UI/UX.',
    const LinearGradient(colors: [Color(0xFF1A1A35), Color(0xFF0C0C20)]),
    KeleleColors.pink,
  ),
  _HeroSlide(
    'For Clients',
    'Hire with\nconfidence.',
    'Browse verified portfolios, filter by skill and budget, and connect directly with the right creative.',
    const LinearGradient(colors: [Color(0xFFFF1A66), Color(0xFFC40041)]),
    KeleleColors.yellow,
  ),
  _HeroSlide(
    'For Creatives',
    'Get discovered.\nGet hired.',
    "Showcase your work to clients who value quality. Join Uganda's best multimedia professionals.",
    const LinearGradient(colors: [Color(0xFF0C0C20), Color(0xFFC40041)]),
    KeleleColors.pink,
  ),
];

class AuthScreen extends ConsumerStatefulWidget {
  final bool isLogin;
  const AuthScreen({super.key, this.isLogin = true});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isLogin;
  int _slide = 0;
  Timer? _timer;

  UserRole? _role;
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _showPass = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() => _slide = (_slide + 1) % _slides.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _submit() {
    final auth = ref.read(authProvider.notifier);
    String? err;
    if (_isLogin) {
      err = auth.login(_emailC.text.trim(), _passC.text);
    } else {
      if (_role == null) {
        setState(() => _error = 'Select a role');
        return;
      }
      err = auth.signup(
          _nameC.text.trim(), _emailC.text.trim(), _passC.text, _role!);
    }
    if (err != null) {
      setState(() => _error = err);
    }
    // Navigation handled by GoRouter redirect
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 800;
    final current = _slides[_slide];

    return Scaffold(
      body: Row(
        children: [
          // ─── LEFT: FORM ─────────────────────
          SizedBox(
            width: wide ? 440 : double.infinity,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Row(children: [
                        Text('Kelele',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                        Text('.',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: KeleleColors.pink)),
                      ]),
                      const SizedBox(height: 48),

                      // Heading
                      Text(
                        _isLogin ? 'Log in, friend.' : 'Join the collective.',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 26, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isLogin
                            ? 'Welcome back! Please enter your details.'
                            : 'Create your account to get started.',
                        style: TextStyle(
                            fontSize: 14, color: KeleleColors.grayMid),
                      ),

                      // Role picker (signup only)
                      if (!_isLogin) ...[
                        const SizedBox(height: 24),
                        Row(children: [
                          _RoleCard(
                            icon: Icons.work_outline,
                            label: 'Finder',
                            desc: 'Hire creative talent',
                            selected: _role == UserRole.finder,
                            onTap: () =>
                                setState(() => _role = UserRole.finder),
                          ),
                          const SizedBox(width: 10),
                          _RoleCard(
                            icon: Icons.palette_outlined,
                            label: 'Creative',
                            desc: 'Showcase your work',
                            selected: _role == UserRole.creative,
                            onTap: () =>
                                setState(() => _role = UserRole.creative),
                          ),
                        ]),
                      ],

                      const SizedBox(height: 24),

                      // Error
                      if (_error != null)
                        Container(
                          width: double.infinity,
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
                                  fontSize: 12, color: Color(0xFFCC0000))),
                        ),

                      // Name (signup only)
                      if (!_isLogin) ...[
                        Text('Full Name',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: KeleleColors.grayMid)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameC,
                          decoration:
                              const InputDecoration(hintText: 'Your name'),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email
                      Text('Email',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: KeleleColors.grayMid)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailC,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            hintText: 'you@example.com'),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      Text('Password',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: KeleleColors.grayMid)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passC,
                        obscureText: !_showPass,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: 'Min. 6 characters',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPass
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18,
                              color: KeleleColors.grayMid,
                            ),
                            onPressed: () =>
                                setState(() => _showPass = !_showPass),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(
                              _isLogin ? 'Sign In' : 'Create Account'),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin ? 'No account? ' : 'Have an account? ',
                            style: TextStyle(
                                fontSize: 13, color: KeleleColors.grayMid),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _isLogin = !_isLogin;
                              _error = null;
                            }),
                            child: Text(
                              _isLogin ? 'Sign up' : 'Sign in',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: KeleleColors.pink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Apply as creator
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: KeleleColors.grayLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text('Are you a creative?',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => context.go('/apply'),
                              child: Text(
                                'Apply to join the directory →',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: KeleleColors.pink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── RIGHT: HERO PANEL ──────────────
          if (wide)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(gradient: current.bg),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -100,
                      right: -80,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -60,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(64),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(children: [
                            Text('Kelele',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.9))),
                            Text('.',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.4))),
                          ]),
                          const SizedBox(height: 32),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              key: ValueKey(_slide),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  current.label.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  current.headline,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w700,
                                    height: 1.08,
                                    letterSpacing: -1,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  current.sub,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.7,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Stats
                          Row(
                            children: [
                              _StatItem('50+', 'Creators', current.accent),
                              const SizedBox(width: 40),
                              _StatItem('8', 'Disciplines', current.accent),
                              const SizedBox(width: 40),
                              _StatItem('100%', 'Vetted', current.accent),
                            ],
                          ),
                          const SizedBox(height: 40),
                          // Dots
                          Row(
                            children: List.generate(
                              _slides.length,
                              (i) => GestureDetector(
                                onTap: () => setState(() => _slide = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: i == _slide ? 24 : 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: i == _slide
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Role picker card ────────────────────────────
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label, desc;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? KeleleColors.pink : KeleleColors.grayBorder,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: selected ? KeleleColors.pinkGlow : Colors.white,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? KeleleColors.pink : KeleleColors.grayLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    size: 20,
                    color: selected ? Colors.white : KeleleColors.grayMid),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(desc,
                  style: TextStyle(
                      fontSize: 10, color: KeleleColors.grayMid)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat item for hero panel ────────────────────
class _StatItem extends StatelessWidget {
  final String value, label;
  final Color accent;
  const _StatItem(this.value, this.label, this.accent);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 22, fontWeight: FontWeight.w700, color: accent)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                color: Colors.white.withOpacity(0.5))),
      ],
    );
  }
}
