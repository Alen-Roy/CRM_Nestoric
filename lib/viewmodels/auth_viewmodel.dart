import 'package:crm/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  AuthState({this.status = AuthStatus.initial, this.errorMessage});
}

class AuthNotifier extends Notifier<AuthState> {
  final _repo = AuthRepository();
  @override
  AuthState build() => AuthState(status: AuthStatus.initial);
  Future<void> login(String email, String password) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      await _repo.login(email, password);
      state = AuthState(status: AuthStatus.authenticated);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> register(String email, String password) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      await _repo.register(email, password);
      state = AuthState(status: AuthStatus.authenticated);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    state = AuthState(status: AuthStatus.loading);
    try {
      await _repo.signOut();
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
