import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/announcement_model.dart';
import 'package:crm/repositories/announcement_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

// ── providers ─────────────────────────────────────────────────────────────────
final _announcementsProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  return AnnouncementRepository().stream();
});

final _recentActivitiesNotifProvider =
    StreamProvider<List<_ActivityItem>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('activities')
      .where('createdBy', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final d = doc.data();
            final type = d['type'] as String? ?? 'note';
            final outcome = d['outcome'] as String?;
            final createdAt = d['createdAt'] != null
                ? (d['createdAt'] as Timestamp).toDate()
                : DateTime.now();
            final label = _typeLabel(type);
            return _ActivityItem(
              icon: _typeIcon(type),
              title:
                  outcome != null && outcome.isNotEmpty ? '$label: $outcome' : '$label logged',
              time: createdAt,
            );
          }).toList());
});

IconData _typeIcon(String t) {
  switch (t) {
    case 'call':     return Symbols.call;
    case 'meeting':  return Symbols.handshake;
    case 'email':    return Symbols.mail;
    case 'proposal': return Symbols.description;
    default:         return Symbols.edit_note;
  }
}

String _typeLabel(String t) {
  switch (t) {
    case 'call':     return 'Call';
    case 'meeting':  return 'Meeting';
    case 'email':    return 'Email';
    case 'proposal': return 'Proposal';
    default:         return 'Note';
  }
}

class _ActivityItem {
  final IconData icon;
  final String title;
  final DateTime time;
  const _ActivityItem({required this.icon, required this.title, required this.time});
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});
  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(_announcementsProvider);
    final activitiesAsync    = ref.watch(_recentActivitiesNotifProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textDark, size: 17),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Notifications',
                    style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ),
              // Unread badge
              announcementsAsync.maybeWhen(
                data: (list) => list.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${list.length}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),
            ]),
          ),

          // ── Tabs ─────────────────────────────────────────────────────────
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                controller: _tabs,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMid,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(11),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Notices'),
                  Tab(text: 'Activity'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Tab views ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                // Tab 1 — Announcements
                announcementsAsync.when(
                  loading: () => const _LoadingView(),
                  error:   (_, __) => const _EmptyView(
                      icon: Symbols.error,
                      message: 'Failed to load notices'),
                  data: (list) => list.isEmpty
                      ? const _EmptyView(
                          icon: Symbols.campaign,
                          message: 'No notices yet')
                      : _AnnouncementList(items: list),
                ),

                // Tab 2 — Recent activity
                activitiesAsync.when(
                  loading: () => const _LoadingView(),
                  error:   (_, __) => const _EmptyView(
                      icon: Symbols.error,
                      message: 'Failed to load activity'),
                  data: (list) => list.isEmpty
                      ? const _EmptyView(
                          icon: Symbols.timeline,
                          message: 'No recent activity')
                      : _ActivityList(items: list),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Announcements list
// ─────────────────────────────────────────────────────────────────────────────
class _AnnouncementList extends StatelessWidget {
  final List<AnnouncementModel> items;
  const _AnnouncementList({required this.items});

  @override
  Widget build(BuildContext context) {
    // Pinned first
    final sorted = [...items]..sort((a, b) {
        if (a.isPinned == b.isPinned) return 0;
        return a.isPinned ? -1 : 1;
      });

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _AnnouncementTile(item: sorted[i]),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final AnnouncementModel item;
  const _AnnouncementTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPinned = item.isPinned;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPinned ? AppColors.primaryGradient : null,
        color: isPinned ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: isPinned
            ? null
            : Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: isPinned
                ? AppColors.primary.withOpacity(0.25)
                : AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isPinned
                ? Colors.white.withOpacity(0.20)
                : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPinned ? Icons.push_pin_rounded : Icons.campaign_outlined,
            color: isPinned ? Colors.white : AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(item.title,
                    style: TextStyle(
                        color: isPinned ? Colors.white : AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              if (isPinned)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Pinned',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700)),
                ),
            ]),
            const SizedBox(height: 4),
            Text(item.body,
                style: TextStyle(
                    color: isPinned
                        ? Colors.white.withOpacity(0.85)
                        : AppColors.textMid,
                    fontSize: 12,
                    height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(
              '— ${item.adminName}',
              style: TextStyle(
                  color: isPinned
                      ? Colors.white.withOpacity(0.65)
                      : AppColors.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity list
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityList extends StatelessWidget {
  final List<_ActivityItem> items;
  const _ActivityList({required this.items});

  @override
  Widget build(BuildContext context) {
    // Group by date
    final groups = <String, List<_ActivityItem>>{};
    for (final item in items) {
      final key = _dateLabel(item.time);
      groups.putIfAbsent(key, () => []).add(item);
    }

    final sections = groups.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      itemCount: sections.length,
      itemBuilder: (_, si) {
        final section = sections[si];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Date header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(section.key,
                style: const TextStyle(
                    color: AppColors.textMid,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: section.value.asMap().entries.map((e) {
                final item   = e.value;
                final isLast = e.key == section.value.length - 1;
                return Column(children: [
                  _ActivityTile(item: item),
                  if (!isLast)
                    const Divider(
                        color: AppColors.divider,
                        height: 1,
                        indent: 64),
                ]);
              }).toList(),
            ),
          ),
        ]);
      },
    );
  }

  static String _dateLabel(DateTime dt) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(dt.year, dt.month, dt.day);
    final diff  = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEEE, d MMM').format(dt);
  }
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;
  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.title,
                style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Text(DateFormat('h:mm a').format(item.time),
              style: const TextStyle(
                  color: AppColors.textLight, fontSize: 11)),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Utils
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
      child:
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2));
}

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyView({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: AppColors.primaryMid, size: 30),
          ),
          const SizedBox(height: 14),
          Text(message,
              style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}
