import 'package:crm/viewmodels/client_viewmodel.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:crm/viewmodels/task_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// ── Result types ──────────────────────────────────────────────────────────────
enum SearchResultType { lead, client, task }

class SearchResult {
  final SearchResultType type;
  final String title;
  final String subtitle;
  final String? badge; // stage / status / priority
  final Object data; // LeadModel | ClientModel | TaskModel

  const SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.data,
  });
}

class SearchResults {
  final List<SearchResult> leads;
  final List<SearchResult> clients;
  final List<SearchResult> tasks;

  const SearchResults({
    this.leads = const [],
    this.clients = const [],
    this.tasks = const [],
  });

  bool get isEmpty => leads.isEmpty && clients.isEmpty && tasks.isEmpty;
  int get total => leads.length + clients.length + tasks.length;
}

// ── Query state ───────────────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');

// ── Search provider ───────────────────────────────────────────────────────────
// Pure in-memory filtering — reuses already-loaded Riverpod streams.
// No extra Firestore reads.
final searchResultsProvider = Provider<SearchResults>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.length < 2) return const SearchResults();

  final leadsAsync = ref.watch(leadsProvider);
  final clientsAsync = ref.watch(clientsStreamProvider);
  final tasksAsync = ref.watch(tasksStreamProvider);

  // ── Leads ─────────────────────────────────────────────────────────────────
  final leadResults = <SearchResult>[];
  for (final l in leadsAsync.value ?? []) {
    if (l.stage == 'Won' || l.stage == 'Lost') continue; // clients cover Won
    final match = _contains(query, [
      l.name,
      l.companyName,
      l.email,
      l.phone,
      l.stage,
      l.service,
      l.city,
    ]);
    if (match) {
      leadResults.add(
        SearchResult(
          type: SearchResultType.lead,
          title: l.name,
          subtitle: [
            l.companyName,
            l.phone,
          ].where((s) => s != null && s!.isNotEmpty).join(' · '),
          badge: l.stage,
          data: l,
        ),
      );
    }
  }

  // ── Clients ───────────────────────────────────────────────────────────────
  final clientResults = <SearchResult>[];
  for (final c in clientsAsync.value ?? []) {
    final match = _contains(query, [
      c.name,
      c.companyName,
      c.email,
      c.phone,
      c.status,
      c.service,
      c.city,
    ]);
    if (match) {
      clientResults.add(
        SearchResult(
          type: SearchResultType.client,
          title: c.name,
          subtitle: [
            c.companyName,
            c.phone,
          ].where((s) => s != null && s!.isNotEmpty).join(' · '),
          badge: c.status,
          data: c,
        ),
      );
    }
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────
  final taskResults = <SearchResult>[];
  for (final t in tasksAsync.value ?? []) {
    if (t.isDone) continue; // hide completed tasks from search
    final match = _contains(query, [t.title, t.notes, t.priority]);
    if (match) {
      final d = t.scheduledAt;
      final now = DateTime.now();
      final isToday =
          d.year == now.year && d.month == now.month && d.day == now.day;
      final isTomorrow =
          d.year == now.year && d.month == now.month && d.day == now.day + 1;
      final dateLabel = isToday
          ? 'Today'
          : isTomorrow
          ? 'Tomorrow'
          : '${d.day}/${d.month}/${d.year}';

      taskResults.add(
        SearchResult(
          type: SearchResultType.task,
          title: t.title,
          subtitle: '$dateLabel · ${t.priority} priority',
          badge: t.priority,
          data: t,
        ),
      );
    }
  }

  return SearchResults(
    leads: leadResults,
    clients: clientResults,
    tasks: taskResults,
  );
});

// ── Helper ────────────────────────────────────────────────────────────────────
bool _contains(String query, List<String?> fields) {
  return fields.any((f) => f != null && f.toLowerCase().contains(query));
}
