import 'package:crm/models/lead_model.dart';
import 'package:crm/repositories/lead_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Repository ────────────────────────────────────────────────────────────────
final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  return LeadRepository();
});

// ── All leads for the current user (real-time Firestore stream) ───────────────
final leadsProvider = StreamProvider<List<LeadModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  final repository = ref.watch(leadRepositoryProvider);
  return repository.getLeads(user.uid);
});

// NOTE: clientsProvider was removed.
// Clients are now a separate Firestore collection managed by client_viewmodel.dart.
// Use: ref.watch(clientsStreamProvider) from package:crm/viewmodels/client_viewmodel.dart
