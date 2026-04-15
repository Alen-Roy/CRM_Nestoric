import 'package:crm/models/user_models.dart';
import 'package:crm/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Current logged-in user's Firestore profile (with isAdmin) ─────────────────
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  return UserRepository().currentUserStream();
});

// ── All users (admin-only) ────────────────────────────────────────────────────
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return UserRepository().allUsersStream();
});

// ── Notifier for admin actions (create admin, toggle role) ────────────────────
class AdminUserNotifier extends AsyncNotifier<void> {
  final _repo = UserRepository();

  @override
  Future<void> build() async {}

  Future<void> createAdmin({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.createAdminUser(email: email, password: password, name: name),
    );
  }

  Future<void> toggleAdmin(String uid, {required bool isAdmin}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.setAdminRole(uid, isAdmin: isAdmin),
    );
  }
}

final adminUserProvider =
    AsyncNotifierProvider<AdminUserNotifier, void>(AdminUserNotifier.new);
