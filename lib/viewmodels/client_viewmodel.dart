import 'package:crm/models/client_model.dart';
import 'package:crm/repositories/client_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Repository provider ───────────────────────────────────────────────────────
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository();
});

// ── Clients stream from Firestore ─────────────────────────────────────────────
// Replaces the old clientsProvider (which was just a filtered leads list).
final clientsStreamProvider = StreamProvider<List<ClientModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  final repo = ref.watch(clientRepositoryProvider);
  return repo.getClients(user.uid);
});
