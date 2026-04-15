import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/models/lead_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Admin stats model ─────────────────────────────────────────────────────────
class AdminStats {
  final int totalLeads;
  final int totalClients;
  final int dealsWon;
  final double totalRevenue;
  final int totalUsers;

  const AdminStats({
    required this.totalLeads,
    required this.totalClients,
    required this.dealsWon,
    required this.totalRevenue,
    required this.totalUsers,
  });

  double get winRate => totalLeads == 0 ? 0 : dealsWon / totalLeads * 100;
}

// ── Leaderboard entry ─────────────────────────────────────────────────────────
class LeaderEntry {
  final String userId;
  final String name;
  final int wonCount;
  final int totalLeads;
  final double revenue;

  const LeaderEntry({
    required this.userId,
    required this.name,
    required this.wonCount,
    required this.totalLeads,
    required this.revenue,
  });
}

// ── All leads (no createdBy filter) ──────────────────────────────────────────
final adminAllLeadsProvider = StreamProvider<List<LeadModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('leads')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => LeadModel.fromMap(d.data(), d.id)).toList());
});

// ── All clients (no createdBy filter) ────────────────────────────────────────
final adminAllClientsProvider = StreamProvider<List<ClientModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('clients')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => ClientModel.fromMap(d.data(), d.id)).toList());
});

// ── Total user count ──────────────────────────────────────────────────────────
final adminUserCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((s) => s.docs.length);
});

// ── Derived admin stats ───────────────────────────────────────────────────────
final adminStatsProvider = Provider<AsyncValue<AdminStats>>((ref) {
  final leadsAsync   = ref.watch(adminAllLeadsProvider);
  final clientsAsync = ref.watch(adminAllClientsProvider);
  final usersAsync   = ref.watch(adminUserCountProvider);

  if (leadsAsync is AsyncLoading ||
      clientsAsync is AsyncLoading ||
      usersAsync is AsyncLoading) {
    return const AsyncLoading();
  }

  if (leadsAsync is AsyncError) return AsyncError(leadsAsync.error!, leadsAsync.stackTrace!);

  final leads   = leadsAsync.value ?? [];
  final clients = clientsAsync.value ?? [];
  final users   = usersAsync.value ?? 0;

  final won = leads.where((l) => l.stage == 'Won').toList();
  final revenue = won.fold<double>(
    0,
    (sum, l) => sum + (double.tryParse(l.amount ?? '0') ?? 0),
  );

  return AsyncData(AdminStats(
    totalLeads:   leads.length,
    totalClients: clients.length,
    dealsWon:     won.length,
    totalRevenue: revenue,
    totalUsers:   users,
  ));
});

// ── Leaderboard (top reps by won deals) ──────────────────────────────────────
final adminLeaderboardProvider = StreamProvider<List<LeaderEntry>>((ref) {
  return FirebaseFirestore.instance
      .collection('leads')
      .snapshots()
      .asyncMap((snap) async {
    final leads = snap.docs.map((d) => LeadModel.fromMap(d.data(), d.id));

    // Group by userId
    final Map<String, List<LeadModel>> grouped = {};
    for (final l in leads) {
      grouped.putIfAbsent(l.userId, () => []).add(l);
    }

    // Fetch user display names from Firestore
    final entries = <LeaderEntry>[];
    for (final entry in grouped.entries) {
      final uid  = entry.key;
      final uLeads = entry.value;
      final won  = uLeads.where((l) => l.stage == 'Won');
      final revenue = won.fold<double>(
        0,
        (s, l) => s + (double.tryParse(l.amount ?? '0') ?? 0),
      );

      // Get user display name
      String name = uid;
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (userDoc.exists) {
          name = userDoc.data()?['name'] ?? uid;
        }
      } catch (_) {}

      entries.add(LeaderEntry(
        userId:     uid,
        name:       name.isEmpty ? uid : name,
        wonCount:   won.length,
        totalLeads: uLeads.length,
        revenue:    revenue,
      ));
    }

    entries.sort((a, b) => b.wonCount.compareTo(a.wonCount));
    return entries;
  });
});
