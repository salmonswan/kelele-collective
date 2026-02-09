enum UserRole { finder, creative, admin }

class AppUser {
  final String name;
  final String email;
  final UserRole role;
  final String initials;

  const AppUser({
    required this.name,
    required this.email,
    required this.role,
    required this.initials,
  });
}
