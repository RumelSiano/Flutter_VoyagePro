import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/company.dart';
import 'crud_service.dart';

/// Wraps Firebase Authentication and the matching `users`/`companies`
/// Firestore writes that happen on registration.
class AuthService {
  AuthService({FirebaseAuth? auth, CrudService? crud})
      : _auth = auth ?? FirebaseAuth.instance,
        _crud = crud ?? CrudService();

  final FirebaseAuth _auth;
  final CrudService _crud;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> login({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Creates the Firebase Auth account, then the matching `users` doc, and
  /// — if [role] is [AppUser.roleAgency] — a `companies` doc tied to it.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? agencyName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    String? companyId;
    if (role == AppUser.roleAgency) {
      final companyRef = await _crud.createCompany(
        Company(ownerUid: uid, name: agencyName ?? name),
      );
      companyId = companyRef.id;
    }

    await _crud.createUserDoc(
      uid,
      AppUser(
        uid: uid,
        name: name,
        email: email,
        role: role,
        companyId: companyId,
      ).toMap(),
    );
  }

  Future<void> logout() => _auth.signOut();
}
