import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/meeting_session_model.dart';
import 'package:crm/viewmodels/meeting_session_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingHistoryPage extends ConsumerWidget {
  final String userId;
  final String workerName;
  const MeetingHistoryPage(
      {super.key, required this.userId, required this.workerName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workerMeetingHistoryProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 24),
                child: Row(children: [
                  IconButton(
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Meeting History',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                          Text(workerName,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13)),
                        ]),
                  ),
                  // Summary badge shown once data is loaded
                  historyAsync.when(
                    data: (list) => _SummaryBadge(sessions: list),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ]),
              ),
            ),
          ),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2)),
              error: (e, _) => Center(
                  child: Text('Error: $e',
                      style:
                          const TextStyle(color: AppColors.danger))),
              data: (sessions) {
                if (sessions.isEmpty) {
                  return _EmptyState(workerName: workerName);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _SessionCard(session: sessions[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary badge ─────────────────────────────────────────────────────────────
class _SummaryBadge extends StatelessWidget {
  final List<MeetingSessionModel> sessions;
  const _SummaryBadge({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final total = sessions.length;
    final withLocation = sessions.where((s) => s.lat != null).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        Text('$total',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        Text('meetings',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10)),
        if (withLocation < total)
          Text('$withLocation with GPS',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 9)),
      ]),
    );
  }
}

// ── Individual session card ───────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final MeetingSessionModel session;
  const _SessionCard({required this.session});

  static final _dateFmt = DateFormat('d MMM yyyy');
  static final _timeFmt = DateFormat('hh:mm a');

  Future<void> _openMap() async {
    if (session.lat == null || session.lng == null) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${session.lat},${session.lng}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = session.isActive;
    final hasLocation = session.lat != null && session.lng != null;
    final borderColor =
        isActive ? AppColors.success : AppColors.border;
    final dot = isActive ? AppColors.success : AppColors.primaryMid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Top row: status dot + name + type badge ──────────────────────
        Row(children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              session.leadName,
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ),
          // Source badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: session.sourceType == 'client'
                  ? AppColors.primarySoft
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              session.sourceType == 'client' ? 'Client' : 'Lead',
              style: TextStyle(
                  color: session.sourceType == 'client'
                      ? AppColors.primary
                      : AppColors.primaryGlow,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('LIVE',
                  style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
          ],
        ]),

        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 12),

        // ── Date + time row ──────────────────────────────────────────────
        Row(children: [
          _infoChip(Icons.calendar_today_rounded,
              _dateFmt.format(session.startTime)),
          const SizedBox(width: 10),
          _infoChip(Icons.access_time_rounded,
              _timeFmt.format(session.startTime)),
          const Spacer(),
          _infoChip(Icons.timer_outlined, session.durationLabel),
        ]),

        const SizedBox(height: 10),

        // ── Location row ────────────────────────────────────────────────
        if (hasLocation)
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.location_pin,
                      color: AppColors.primary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${session.lat!.toStringAsFixed(5)}, '
                    '${session.lng!.toStringAsFixed(5)}',
                    style: const TextStyle(
                        color: AppColors.textMid,
                        fontSize: 11,
                        fontFamily: 'monospace'),
                  ),
                ]),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _openMap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(children: [
                  Icon(Icons.map_rounded, color: Colors.white, size: 13),
                  SizedBox(width: 5),
                  Text('Open Map',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ])
        else
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(children: [
              Icon(Icons.location_off_rounded,
                  color: AppColors.danger, size: 13),
              SizedBox(width: 6),
              Text('No location recorded for this meeting',
                  style: TextStyle(
                      color: AppColors.danger, fontSize: 11)),
            ]),
          ),

        // ── End time ────────────────────────────────────────────────────
        if (!isActive && session.endTime != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.stop_circle_outlined,
                color: AppColors.textLight, size: 13),
            const SizedBox(width: 6),
            Text(
              'Ended at ${_timeFmt.format(session.endTime!)}',
              style: const TextStyle(
                  color: AppColors.textLight, fontSize: 11),
            ),
          ]),
        ],
      ]),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.textLight),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(
              color: AppColors.textMid, fontSize: 11)),
    ]);
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String workerName;
  const _EmptyState({required this.workerName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.handshake_rounded,
                color: AppColors.primaryGlow, size: 38),
          ),
          const SizedBox(height: 20),
          const Text('No Meetings Yet',
              style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            '$workerName has not started any meetings yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textMid, fontSize: 13),
          ),
        ]),
      ),
    );
  }
}
