enum UserRole { finder, creative, admin }

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String initials;
  final List<String> bookmarks;
  final bool isGuest;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.initials,
    this.bookmarks = const [],
    this.isGuest = false,
  });

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => UserRole.finder,
      ),
      initials: data['initials'] ?? '',
      bookmarks: List<String>.from(data['bookmarks'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'role': role.name,
        'initials': initials,
        'bookmarks': bookmarks,
      };
}
