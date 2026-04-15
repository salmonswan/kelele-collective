import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final mobile = screenW < 600;

    return Scaffold(
      backgroundColor: KeleleColors.dark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/c9cdf340-e019-4398-bcf7-a3efb29cccb1.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Waitlist button at bottom center
          Positioned(
            bottom: mobile ? 60 : 80,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () => _showWaitlistDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KeleleColors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 18,
                  ),
                  shape: const StadiumBorder(),
                  textStyle: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Join the Waitlist'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWaitlistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _WaitlistDialog(),
    );
  }
}

class _WaitlistDialog extends StatefulWidget {
  const _WaitlistDialog();

  @override
  State<_WaitlistDialog> createState() => _WaitlistDialogState();
}

class _WaitlistDialogState extends State<_WaitlistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _skillsC = TextEditingController();
  final _summaryC = TextEditingController();
  bool _loading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _skillsC.dispose();
    _summaryC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameC.text.trim().isEmpty ||
        _emailC.text.trim().isEmpty ||
        _skillsC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final email = _emailC.text.trim().toLowerCase();
      await FirebaseFirestore.instance.collection('waitlist').doc(email).set({
        'name': _nameC.text.trim(),
        'email': email,
        'skills': _skillsC.text.trim(),
        'summary': _summaryC.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        _loading = false;
        _submitted = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          backgroundColor: KeleleColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: mobile ? 16 : 40,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _submitted ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Padding(
      key: const ValueKey('success'),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: KeleleColors.greenGlow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: KeleleColors.green,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "You're on the list!",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: KeleleColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll notify you when we launch.",
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: KeleleColors.grayMid,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Join as a Creator',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: KeleleColors.dark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Kelele is invite-only. Share your details and we\'ll review your application.',
              style: TextStyle(
                fontSize: 13,
                color: KeleleColors.grayMid,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Vetting badge
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
                        color: KeleleColors.pinkDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Full Name
            _FieldLabel('Full Name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameC,
              decoration: const InputDecoration(hintText: 'Your full name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),

            // Email
            _FieldLabel('Email'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailC,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'you@example.com'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Skills / Disciplines
            _FieldLabel('Skills / Disciplines'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _skillsC,
              decoration: const InputDecoration(
                hintText: 'e.g. Photography, Motion Design',
              ),
            ),
            const SizedBox(height: 14),

            // Tell us about your work
            _FieldLabel('Tell us about your work'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _summaryC,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Brief summary of your experience, links to your portfolio...',
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KeleleColors.pink,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit Application',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: KeleleColors.dark,
      ),
    );
  }
}
