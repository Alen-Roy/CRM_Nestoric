import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/activity_model.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/models/task_model.dart';
import 'package:crm/models/user_models.dart';
import 'package:crm/viewmodels/user_role_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm/models/announcement_model.dart';
import 'package:crm/repositories/announcement_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────
class AdminStats {
  final int totalLeads;
  final int totalClients;
  final int totalTasks;
  final int dealsWon;
  final double totalRevenue;
  final int totalUsers;
  final int activitiesLogged;

  const AdminStats({
    required this.totalLeads,
    required this.totalClients,
    required this.totalTasks,
    required this.dealsWon,
    required this.totalRevenue,
    required this.totalUsers,
    required this.activitiesLogged,
  });

  double get winRate => totalLeads == 0 ? 0 : dealsWon / totalLeads * 100;
}

class LeaderEntry {
  final String userId;
  final String name;
  final int wonCount;
  final int totalLeads;
  final double revenue;
  final int tasksCompleted;
  final int activitiesLogged;

  const LeaderEntry({
    required this.userId,
    required this.name,
    required this.wonCount,
    required this.totalLeads,
    required this.revenue,
    required this.tasksCompleted,
    required this.activitiesLogged,
  });

  double get winRate => totalLeads == 0 ? 0 : wonCount / totalLeads * 100;
}

class WorkerSummary {
  final String userId;
  final String name;
  final String email;
  final List<LeadModel> leads;
  final List<TaskModel> tasks;
  final List<ActivityModel> activities;

  const WorkerSummary({
    required this.userId,
    required this.name,
    required this.email,
    required this.leads,
    required this.tasks,
    required this.activities,
  });

  int get wonLeads       => leads.where((l) => l.stage == 'Won').length;
  int get activeLeads    => leads.where((l) => l.stage != 'Won' && l.stage != 'Lost').length;
  int get tasksCompleted => tasks.where((t) => t.isDone).length;
  int get tasksPending   => tasks.where((t) => !t.isDone).length;
  double get revenue => leads
      .where((l) => l.stage == 'Won')
      .fold(0, (s, l) => s + (double.tryParse(l.amount ?? '0') ?? 0));
  double get winRate => leads.isEmpty ? 0 : wonLeads / leads.length * 100;
}

/// A feed entry shown in the admin overview's live activity stream.
class ActivityFeedEntry {
  final ActivityModel activity;
  final String workerName;
  final String leadName;

  const ActivityFeedEntry({
    required this.activity,
    required this.workerName,
    required this.leadName,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Firestore Streams — No user filter (org-wide)
// ─────────────────────────────────────────────────────────────────────────────

final adminAllLeadsProvider = StreamProvider<List<LeadModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('leads')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => LeadModel.fromMap(d.data(), d.id)).toList());
});

final adminAllClientsProvider = StreamProvider<List<ClientModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('clients')
      .orderBy('joinedDate', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => ClientModel.fromMap(d.data(), d.id)).toList());
});

final adminAllTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('tasks')
      .orderBy('scheduledAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => TaskModel.fromMap(d.data(), d.id)).toList());
});

final adminAllActivitiesProvider = StreamProvider<List<ActivityModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('activities')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => ActivityModel.fromMap(d.data(), d.id)).toList());
});

final adminUserCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((s) => s.docs.length);
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived: Admin KPI stats
// ─────────────────────────────────────────────────────────────────────────────
final adminStatsProvider = Provider<AsyncValue<AdminStats>>((ref) {
  final leadsA  = ref.watch(adminAllLeadsProvider);
  final clientA = ref.watch(adminAllClientsProvider);
  final tasksA  = ref.watch(adminAllTasksProvider);
  final usersA  = ref.watch(adminUserCountProvider);
  final activA  = ref.watch(adminAllActivitiesProvider);

  if ([leadsA, clientA, tasksA, usersA, activA]
      .any((a) => a is AsyncLoading)) { return const AsyncLoading(); }

  final leads      = leadsA.value  ?? [];
  final clients    = clientA.value ?? [];
  final tasks      = tasksA.value  ?? [];
  final users      = usersA.value  ?? 0;
  final activities = activA.value  ?? [];

  final won     = leads.where((l) => l.stage == 'Won');
  final revenue = won.fold<double>(
      0, (s, l) => s + (double.tryParse(l.amount ?? '0') ?? 0));

  return AsyncData(AdminStats(
    totalLeads:       leads.length,
    totalClients:     clients.length,
    totalTasks:       tasks.length,
    dealsWon:         won.length,
    totalRevenue:     revenue,
    totalUsers:       users,
    activitiesLogged: activities.length,
  ));
});

// ─────────────────────────────────────────────────────────────────────────────
// Helper: Build name-lookup map from users collection
// ─────────────────────────────────────────────────────────────────────────────
/// Returns a map of { uid → displayName } from Firestore users.
final _userNamesMapProvider = Provider<AsyncValue<Map<String, String>>>((ref) {
  final usersA = ref.watch(allUsersProvider);
  return usersA.whenData((users) => {
    for (final u in users) u.uid: (u.name?.isNotEmpty == true ? u.name! : u.email),
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived: Leaderboard (with real names from users collection)
// ─────────────────────────────────────────────────────────────────────────────
final adminLeaderboardProvider = Provider<AsyncValue<List<LeaderEntry>>>((ref) {
  final leadsA  = ref.watch(adminAllLeadsProvider);
  final tasksA  = ref.watch(adminAllTasksProvider);
  final activA  = ref.watch(adminAllActivitiesProvider);
  final namesA  = ref.watch(_userNamesMapProvider);

  if ([leadsA, tasksA, activA, namesA].any((a) => a is AsyncLoading)) {
    return const AsyncLoading();
  }

  final leads      = leadsA.value  ?? [];
  final tasks      = tasksA.value  ?? [];
  final activities = activA.value  ?? [];
  final names      = namesA.value  ?? {};

  // Group leads by userId
  final Map<String, List<LeadModel>> leadsByUser = {};
  for (final l in leads) {
    leadsByUser.putIfAbsent(l.userId, () => []).add(l);
  }

  // Group tasks done by userId
  final Map<String, int> tasksDoneByUser = {};
  for (final t in tasks) {
    if (t.isDone) {
      tasksDoneByUser[t.userId] = (tasksDoneByUser[t.userId] ?? 0) + 1;
    }
  }

  // Group activities by createdBy
  final Map<String, int> activByUser = {};
  for (final a in activities) {
    activByUser[a.createdBy] = (activByUser[a.createdBy] ?? 0) + 1;
  }

  final entries = leadsByUser.entries.map((e) {
    final uid    = e.key;
    final uLeads = e.value;
    final won    = uLeads.where((l) => l.stage == 'Won');
    final revenue = won.fold<double>(
        0, (s, l) => s + (double.tryParse(l.amount ?? '0') ?? 0));
    // Prefer Firestore user name → assignTo field → short uid
    final displayName = names[uid]
        ?? (uLeads.first.assignTo?.isNotEmpty == true ? uLeads.first.assignTo! : uid.substring(0, uid.length < 8 ? uid.length : 8));
    return LeaderEntry(
      userId:           uid,
      name:             displayName,
      wonCount:         won.length,
      totalLeads:       uLeads.length,
      revenue:          revenue,
      tasksCompleted:   tasksDoneByUser[uid] ?? 0,
      activitiesLogged: activByUser[uid] ?? 0,
    );
  }).toList()
    ..sort((a, b) => b.wonCount.compareTo(a.wonCount));

  return AsyncData(entries);
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived: Per-worker summaries (Workers tab) — with real names
// ─────────────────────────────────────────────────────────────────────────────
final adminWorkerSummariesProvider = Provider<AsyncValue<List<WorkerSummary>>>((ref) {
  final leadsA = ref.watch(adminAllLeadsProvider);
  final tasksA = ref.watch(adminAllTasksProvider);
  final activA = ref.watch(adminAllActivitiesProvider);
  final usersA = ref.watch(allUsersProvider);

  if ([leadsA, tasksA, activA, usersA].any((a) => a is AsyncLoading)) {
    return const AsyncLoading();
  }

  final leads      = leadsA.value ?? [];
  final tasks      = tasksA.value ?? [];
  final activities = activA.value ?? [];
  final users      = usersA.value ?? <UserModel>[];

  // Build uid → UserModel lookup
  final userMap = {for (final u in users) u.uid: u};

  // Collect all unique worker userIds (non-admins who have data, plus all non-admin users)
  final Set<String> workerIds = {
    ...users.where((u) => !u.isAdmin).map((u) => u.uid),
    ...leads.map((l) => l.userId),
    ...tasks.map((t) => t.userId),
  };

  final summaries = workerIds.map((uid) {
    final user = userMap[uid];
    // Skip admins from this list
    if (user?.isAdmin == true) return null;

    final uLeads  = leads.where((l) => l.userId == uid).toList();
    final uTasks  = tasks.where((t) => t.userId == uid).toList();
    final uActiv  = activities.where((a) => a.createdBy == uid).toList();

    final displayName = (user?.name?.isNotEmpty == true)
        ? user!.name!
        : (user?.email ?? uid.substring(0, uid.length < 8 ? uid.length : 8));

    return WorkerSummary(
      userId:     uid,
      name:       displayName,
      email:      user?.email ?? '',
      leads:      uLeads,
      tasks:      uTasks,
      activities: uActiv,
    );
  }).whereType<WorkerSummary>().toList()
    ..sort((a, b) => b.wonLeads.compareTo(a.wonLeads));

  return AsyncData(summaries);
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived: Live Activity Feed (last 20 entries with worker & lead names)
// ─────────────────────────────────────────────────────────────────────────────
final adminActivityFeedProvider = Provider<AsyncValue<List<ActivityFeedEntry>>>((ref) {
  final activA  = ref.watch(adminAllActivitiesProvider);
  final leadsA  = ref.watch(adminAllLeadsProvider);
  final namesA  = ref.watch(_userNamesMapProvider);

  if ([activA, leadsA, namesA].any((a) => a is AsyncLoading)) {
    return const AsyncLoading();
  }

  final activities = activA.value ?? [];
  final leads      = leadsA.value ?? [];
  final names      = namesA.value ?? {};

  // Build leadId → lead name map
  final leadNames = {for (final l in leads) if (l.id != null) l.id!: l.name};

  final feed = activities.take(20).map((a) {
    final workerName = names[a.createdBy] ?? a.createdBy.substring(0, a.createdBy.length < 8 ? a.createdBy.length : 8);
    final leadName   = leadNames[a.leadId] ?? 'Unknown Lead';
    return ActivityFeedEntry(
      activity:   a,
      workerName: workerName,
      leadName:   leadName,
    );
  }).toList();

  return AsyncData(feed);
});

// ─────────────────────────────────────────────────────────────────────────────
// Admin Actions Notifier (with audit logging)
// ─────────────────────────────────────────────────────────────────────────────
class AdminActionsNotifier extends Notifier<String?> {
  final _db = FirebaseFirestore.instance;

  @override
  String? build() => null;

  // ── Internal: write admin audit log ────────────────────────────────────────
  Future<void> _log(String action, String targetType, String targetId) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) return;
    await _db.collection('adminLogs').add({
      'action':     action,
      'targetType': targetType,
      'targetId':   targetId,
      'adminUid':   adminUid,
      'timestamp':  FieldValue.serverTimestamp(),
    });
  }

  // ── Lead management ────────────────────────────────────────────────────────
  Future<void> changeLeadStage(String leadId, String newStage) async {
    await _db.collection('leads').doc(leadId).update({'stage': newStage});
    await _log('changeLeadStage:$newStage', 'lead', leadId);
    state = 'Lead stage updated to $newStage';
  }

  Future<void> reassignLead(String leadId, String newUserId) async {
    await _db.collection('leads').doc(leadId).update({'userId': newUserId});
    await _log('reassignLead', 'lead', leadId);
    state = 'Lead reassigned';
  }

  Future<void> deleteLead(String leadId) async {
    await _db.collection('leads').doc(leadId).delete();
    await _log('deleteLead', 'lead', leadId);
    state = 'Lead deleted';
  }

  // ── Task management ────────────────────────────────────────────────────────
  Future<void> toggleTask(String taskId, bool isDone) async {
    await _db.collection('tasks').doc(taskId).update({'isDone': isDone});
    await _log(isDone ? 'taskMarkDone' : 'taskReopened', 'task', taskId);
    state = isDone ? 'Task marked done' : 'Task reopened';
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
    await _log('deleteTask', 'task', taskId);
    state = 'Task deleted';
  }

  // ── Client management ──────────────────────────────────────────────────────
  Future<void> changeClientStatus(String clientId, String status) async {
    await _db.collection('clients').doc(clientId).update({'status': status});
    await _log('changeClientStatus:$status', 'client', clientId);
    state = 'Client status updated';
  }

  Future<void> deleteClient(String clientId) async {
    await _db.collection('clients').doc(clientId).delete();
    await _log('deleteClient', 'client', clientId);
    state = 'Client deleted';
  }

  // ── Assign task to a worker ────────────────────────────────────────────────
  Future<void> assignTaskToWorker({
    required String workerUid,
    required String title,
    required String priority,
    required DateTime scheduledAt,
    String? notes,
    String? adminNote,
  }) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final taskRef = await _db.collection('tasks').add({
      'title': title,
      'notes': notes,
      'scheduledAt': scheduledAt,
      'priority': priority,
      'userId': workerUid,
      'assignedTo': workerUid,
      'isAdminTask': true,
      'adminNote': adminNote,
      'isDone': false,
    });
    await _log('assignTask:${taskRef.id}', 'task', workerUid);
    state = 'Task assigned successfully';
  }
}

final adminActionsProvider =
    NotifierProvider<AdminActionsNotifier, String?>(AdminActionsNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Announcements
// ─────────────────────────────────────────────────────────────────────────────

final announcementsProvider = StreamProvider<List<AnnouncementModel>>((ref) =>
    AnnouncementRepository().stream());

class AnnouncementNotifier extends Notifier<void> {
  final _repo = AnnouncementRepository();
  @override void build() {}

  Future<void> post({
    required String title,
    required String body,
    required String adminUid,
    required String adminName,
    bool pinned = false,
  }) => _repo.add(AnnouncementModel(
    title: title, body: body,
    adminUid: adminUid, adminName: adminName,
    createdAt: DateTime.now(), isPinned: pinned,
  ));

  Future<void> delete(String id) => _repo.delete(id);
  Future<void> togglePin(String id, bool pinned) => _repo.togglePin(id, pinned);
}

final announcementNotifierProvider =
    NotifierProvider<AnnouncementNotifier, void>(AnnouncementNotifier.new);
