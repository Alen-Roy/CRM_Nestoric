import 'dart:async';

import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/attendance_model.dart';
import 'package:crm/viewmodels/attendance_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});
  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        ref.read(attendanceProvider.notifier).loadToday(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user        = FirebaseAuth.instance.currentUser;
    final state       = ref.watch(attendanceProvider);
    final historyAsync = ref.watch(myAttendanceProvider);

    final userName  = user?.displayName ?? user?.email?.split('@').first ?? 'Employee';
    final userEmail = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      )),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(userName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      Text(userEmail,
                          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
                    ])),
                    // Today's date pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormat('d MMM').format(DateTime.now()),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── Check-in card ─────────────────────────────────────────
                  _CheckInCard(
                    state: state,
                    userName:  userName,
                    userEmail: userEmail,
                    userId:    user?.uid ?? '',
                  ),
                ],
              ),
            ),

            // ── Attendance history ─────────────────────────────────────────
            Expanded(
              child: historyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2)),
                error: (e, _) => Center(child: Text('Error: $e',
                    style: const TextStyle(color: AppColors.danger))),
                data: (records) {
                  if (records.isEmpty) {
                    return _EmptyHistory();
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                    children: [
                      // ── Summary strip ──────────────────────────────────
                      _SummaryStrip(records: records),
                      const SizedBox(height: 20),

                      // ── History heading ────────────────────────────────
                      Row(children: [
                        Container(width: 3, height: 18,
                            decoration: BoxDecoration(color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        const Text('Attendance History',
                            style: TextStyle(color: AppColors.textDark,
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('${records.length} records',
                              style: const TextStyle(color: AppColors.primary,
                                  fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 12),

                      ...records.map((r) => _AttendanceTile(record: r)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Check-in / Check-out action card ─────────────────────────────────────────
class _CheckInCard extends ConsumerWidget {
  final AttendanceState state;
  final String userName;
  final String userEmail;
  final String userId;
  const _CheckInCard({
    required this.state,
    required this.userName,
    required this.userEmail,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record       = state.todayRecord;
    final isCheckedIn  = state.isCheckedIn;
    final hasCheckedOut = state.hasCheckedOut;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasCheckedOut
                    ? Colors.white.withOpacity(0.5)
                    : isCheckedIn
                        ? AppColors.success
                        : Colors.white.withOpacity(0.4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              hasCheckedOut
                  ? 'Checked out — ${DateFormat('h:mm a').format(record!.checkOutTime!)}'
                  : isCheckedIn
                      ? '🟢  Checked in — ${DateFormat('h:mm a').format(record!.checkInTime)}'
                      : 'Not checked in today',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ]),

          if (isCheckedIn && !hasCheckedOut) ...[
            const SizedBox(height: 6),
            _LiveTimer(checkInTime: record!.checkInTime),
          ],

          if (record?.hasLocation == true) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.location_on, color: Colors.white.withOpacity(0.7), size: 13),
              const SizedBox(width: 4),
              Text(
                '${record!.lat!.toStringAsFixed(5)}, ${record.lng!.toStringAsFixed(5)}',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
              ),
            ]),
          ],

          if (state.error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(state.error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 11)),
            ),
          ],

          const SizedBox(height: 14),

          // Action button
          if (state.isLoading)
            const Center(child: SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ))
          else if (!isCheckedIn)
            _ActionButton(
              label: 'Check In',
              icon: Symbols.login,
              onTap: () async {
                final err = await ref.read(attendanceProvider.notifier).checkIn(
                  userId:    userId,
                  userName:  userName,
                  userEmail: userEmail,
                );
                if (err != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(err),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
            )
          else if (!hasCheckedOut)
            _ActionButton(
              label: 'Check Out',
              icon: Symbols.logout,
              isDanger: true,
              onTap: () async {
                final ok = await _confirmCheckOut(context);
                if (ok != true) return;
                final err = await ref.read(attendanceProvider.notifier).checkOut();
                if (err != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(err),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle_rounded, color: Colors.white.withOpacity(0.8), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Attendance marked — ${record!.durationLabel} in office',
                  style: TextStyle(color: Colors.white.withOpacity(0.9),
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  Future<bool?> _confirmCheckOut(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Check Out?',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
      content: const Text('This will mark your departure time for today.',
          style: TextStyle(color: AppColors.textMid)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMid))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Check Out', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// ── Live elapsed timer ────────────────────────────────────────────────────────
class _LiveTimer extends StatefulWidget {
  final DateTime checkInTime;
  const _LiveTimer({required this.checkInTime});
  @override
  State<_LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  late Timer _t;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.checkInTime);
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed = DateTime.now().difference(widget.checkInTime));
      }
    });
  }

  @override
  void dispose() { _t.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final h = _elapsed.inHours;
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final label = h > 0 ? '${h}h $m:$s' : '$m:$s';
    return Text(
      'Time in office: $label',
      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDanger;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: isDanger
            ? AppColors.danger.withOpacity(0.15)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDanger ? AppColors.danger.withOpacity(0.4) : Colors.transparent),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 20,
            color: isDanger ? AppColors.danger : AppColors.primary),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
              color: isDanger ? AppColors.danger : AppColors.primary,
              fontSize: 14, fontWeight: FontWeight.w700,
            )),
      ]),
    ),
  );
}

// ── Summary strip ─────────────────────────────────────────────────────────────
class _SummaryStrip extends StatelessWidget {
  final List<AttendanceModel> records;
  const _SummaryStrip({required this.records});

  @override
  Widget build(BuildContext context) {
    final total    = records.length;
    final withOut  = records.where((r) => r.hasCheckedOut).length;
    // Calculate avg duration in minutes
    final durations = records
        .where((r) => r.duration != null)
        .map((r) => r.duration!.inMinutes)
        .toList();
    final avgMin = durations.isEmpty ? 0 : durations.reduce((a, b) => a + b) ~/ durations.length;
    final avgLabel = avgMin >= 60
        ? '${avgMin ~/ 60}h ${(avgMin % 60).toString().padLeft(2, '0')}m'
        : '${avgMin}m';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        _statCell('$total',   'Total Days',   AppColors.primary),
        _divider(),
        _statCell('$withOut', 'With Checkout', AppColors.success),
        _divider(),
        _statCell(durations.isEmpty ? '—' : avgLabel, 'Avg Hours', AppColors.primaryGlow),
      ]),
    );
  }

  Widget _statCell(String val, String label, Color color) => Expanded(
    child: Column(children: [
      Text(val, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center),
    ]),
  );

  Widget _divider() => Container(
      width: 1, height: 36, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 8));
}

// ── Single attendance record tile ─────────────────────────────────────────────
class _AttendanceTile extends StatelessWidget {
  final AttendanceModel record;
  const _AttendanceTile({required this.record});

  static final _dateFmt = DateFormat('EEE, d MMM yyyy');
  static final _timeFmt = DateFormat('h:mm a');

  Future<void> _openMap() async {
    if (!record.hasLocation) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${record.lat},${record.lng}');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isToday = record.date == AttendanceModel.todayKey();
    final isOngoing = record.isPresent && !record.hasCheckedOut;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOngoing
              ? AppColors.success.withOpacity(0.4)
              : isToday
                  ? AppColors.primarySoft
                  : AppColors.border,
        ),
        boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        // Date column
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: isToday ? AppColors.primaryLight : AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              DateFormat('d').format(record.checkInTime),
              style: TextStyle(
                  color: isToday ? AppColors.primary : AppColors.textDark,
                  fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              DateFormat('MMM').format(record.checkInTime),
              style: TextStyle(
                  color: isToday ? AppColors.primaryGlow : AppColors.textLight,
                  fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ]),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            isToday ? 'Today' : _dateFmt.format(record.checkInTime),
            style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.login_rounded, size: 11, color: AppColors.success),
            const SizedBox(width: 3),
            Text(_timeFmt.format(record.checkInTime),
                style: const TextStyle(color: AppColors.textMid, fontSize: 11)),
            if (record.hasCheckedOut) ...[
              const SizedBox(width: 10),
              Icon(Icons.logout_rounded, size: 11, color: AppColors.danger),
              const SizedBox(width: 3),
              Text(_timeFmt.format(record.checkOutTime!),
                  style: const TextStyle(color: AppColors.textMid, fontSize: 11)),
            ],
          ]),
        ])),

        // Duration badge + map button
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isOngoing
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOngoing ? 'Active' : record.durationLabel,
              style: TextStyle(
                  color: isOngoing ? AppColors.success : AppColors.primary,
                  fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
          if (record.hasLocation) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _openMap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Icon(Icons.location_on, color: Colors.white, size: 10),
                  SizedBox(width: 3),
                  Text('Map', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ],
        ]),
      ]),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(24)),
          child: const Icon(Symbols.calendar_today, color: AppColors.primary, size: 38),
        ),
        const SizedBox(height: 20),
        const Text('No Attendance Yet',
            style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Check in when you arrive at the office.\nYour records will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMid, fontSize: 13, height: 1.5)),
      ]),
    ),
  );
}
