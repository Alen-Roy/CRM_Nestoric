import 'package:crm/models/user_models.dart';
import 'package:crm/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final _auth    = FirebaseAuth.instance;
  final _userRepo = UserRepository();

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Ensure Firestore profile doc exists (first-time login users)
    if (result.user != null) {
      await _userRepo.upsertUser(UserModel(
        uid: result.user!.uid,
        email: email,
        name: result.user!.displayName,
      ));
    }
    return result.user;
  }

  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<void> updateProfile(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  // Called after register so we have the display name
  Future<void> createUserProfile(String uid, String email, String name) async {
    await _userRepo.upsertUser(UserModel(
      uid: uid,
      email: email,
      name: name,
    ));
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authState => _auth.authStateChanges();
}
