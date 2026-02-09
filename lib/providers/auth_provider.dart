import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

const _adminEmails = ['admin@kelele.com', 'tobi@kelele.com'];

class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier() : super(null);

  static String _buildInitials(String name) {
    final parts = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.map((w) => w[0]).take(2).join().toUpperCase();
  }

  String? login(String email, String password) {
    if (email.isEmpty || password.isEmpty) return 'Fill in all fields';
    if (password.length < 6) return 'Password must be 6+ characters';

    final role = _adminEmails.contains(email.toLowerCase())
        ? UserRole.admin
        : UserRole.finder;
    final displayName = email.toLowerCase() == 'tobi@kelele.com'
        ? 'Tobi Fluck'
        : email.split('@').first;
    final initials = email.toLowerCase() == 'tobi@kelele.com'
        ? 'TF'
        : _buildInitials(displayName);

    state = AppUser(
      name: displayName,
      email: email,
      role: role,
      initials: initials,
    );
    return null;
  }

  String? signup(String name, String email, String password, UserRole role) {
    if (name.isEmpty) return 'Enter your name';
    if (email.isEmpty || password.isEmpty) return 'Fill in all fields';
    if (password.length < 6) return 'Password must be 6+ characters';

    final assignedRole = _adminEmails.contains(email.toLowerCase())
        ? UserRole.admin
        : role;
    final initials = _buildInitials(name);

    state = AppUser(
      name: name,
      email: email,
      role: assignedRole,
      initials: initials,
    );
    return null;
  }

  void logout() => state = null;
}

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier();
});
