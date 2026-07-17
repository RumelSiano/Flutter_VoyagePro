/// A row from the `users` collection. `role` decides which shell the
/// role_router_screen sends the person to after login.
class AppUser {
  static const roleAdmin = 'admin';
  static const roleAgency = 'agency';
  static const roleCustomer = 'customer';

  final String uid;
  final String name;
  final String email;
  final String role;
  final String? companyId; // only set when role == roleAgency

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.companyId,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? roleCustomer,
      companyId: map['companyId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'companyId': companyId,
    };
  }
}
