import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/user_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class UserRepository {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ── Create / update user profile doc on register / first login ─────────────
  Future<void> upsertUser(UserModel user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      // First time — create with isAdmin: false
      await ref.set(user.toMap());
    }
    // Existing doc is never overwritten (preserves isAdmin set by admin)
  }

  // ── Stream of the currently logged-in user's profile ───────────────────────
  Stream<UserModel?> currentUserStream() {
    return _auth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) return Stream.value(null);
      return _db
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .map((snap) => snap.exists
              ? UserModel.fromMap(snap.data()!, snap.id)
              : null);
    });
  }

  // ── Stream of all users (admin only) ───────────────────────────────────────
  Stream<List<UserModel>> allUsersStream() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
  }

  // ── Promote / demote admin (admin only) ────────────────────────────────────
  Future<void> setAdminRole(String uid, {required bool isAdmin}) async {
    await _db.collection('users').doc(uid).update({'isAdmin': isAdmin});
  }

  // ── Create a new account (from admin dashboard) ────────────────────────────
  Future<String> createUserAccount({
    required String email,
    required String password,
    required String name,
    required bool isAdmin,
  }) async {
    // Use a secondary FirebaseApp so the admin stays signed in
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'admin_create_temp_${DateTime.now().millisecondsSinceEpoch}',
        options: FirebaseAuth.instance.app.options,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final result = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final newUid = result.user!.uid;
      await result.user!.updateDisplayName(name);
      // Write Firestore doc with appropriate role
      await _db.collection('users').doc(newUid).set(UserModel(
            uid: newUid,
            email: email,
            name: name,
            isAdmin: isAdmin,
            createdAt: DateTime.now(),
          ).toMap());
      await secondaryAuth.signOut();
      return newUid;
    } finally {
      await secondaryApp?.delete();
    }
  }
}
