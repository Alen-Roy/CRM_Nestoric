import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/widgets/activity_timeline.dart';
import 'package:crm/models/activity_model.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/viewmodels/activity_viewmodel.dart';
import 'package:crm/viewmodels/client_viewmodel.dart';
import 'package:crm/viewmodels/meeting_session_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDetailPage extends ConsumerStatefulWidget {
  final ClientModel client;
  const ClientDetailPage({super.key, required this.client});

  @override
  ConsumerState<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends ConsumerState<ClientDetailPage> {
  late ClientModel _client;

  @override
  void initState() {
    super.initState();
    _client = widget.client;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        ref.read(meetingSessionProvider.notifier).loadActiveSession(uid);
      }
    });
  }

  Color _statusColor(String s) {
    switch (s) {
      case ClientStatus.vip:       return AppColors.primaryMid;
      case ClientStatus.active:    return AppColors.primary;
      case ClientStatus.inactive:  return AppColors.textLight;
      default:                     return AppColors.primaryGlow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesProvider(_client.leadId));
    final statusColor = _statusColor(_client.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Premium SliverAppBar header ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 16),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.more_vert, color: AppColors.textDark, size: 18),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      // Avatar with status ring
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryMid, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(_client.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(_client.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      if (_client.companyName != null) ...[
                        const SizedBox(height: 4),
                        Text(_client.companyName!, style: TextStyle(color: AppColors.textMid, fontSize: 13)),
                      ],
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _showStatusSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(_client.status, style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 5),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textDark, size: 14),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Action buttons
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _actionBtn(Icons.call_rounded, 'Call', () async {
                          final uri = Uri.parse('tel:${_client.phone.replaceAll(RegExp(r'[\s\-()]'), '')}');
                          if (await canLaunchUrl(uri)) launchUrl(uri);
                        }),
                        const SizedBox(width: 16),
                        _actionBtn(Icons.chat_rounded, 'WhatsApp', () async {
                          final uri = Uri.parse('https://wa.me/${_client.phone.replaceAll(RegExp(r'[\s\-+()]'), '')}');
                          if (await canLaunchUrl(uri)) launchUrl(uri);
                        }),
                        const SizedBox(width: 16),
                        _actionBtn(Icons.mail_rounded, 'Email', () async {
                          if (_client.email != null) {
                            final uri = Uri.parse('mailto:${_client.email}');
                            if (await canLaunchUrl(uri)) launchUrl(uri);
                          }
                        }),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revenue highlight card
                  if (_client.monthlyValue != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Monthly Value', style: TextStyle(color: AppColors.textMid, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('₹${_client.monthlyValue!.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                        ])),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Symbols.currency_rupee, color: Colors.white, size: 26),
                        ),
                      ]),
                    ),

                  // Contact Details section
                  _sectionTitle('Contact Details'),
                  const SizedBox(height: 12),
                  _infoGrid([
                    _InfoItem(Symbols.mail, 'Email', _client.email ?? '—'),
                    _InfoItem(Symbols.call, 'Phone', _client.phone),
                    _InfoItem(Symbols.location_city, 'City', _client.city ?? '—'),
                    _InfoItem(Symbols.business, 'Company', _client.companyName ?? '—'),
                    _InfoItem(Symbols.home_repair_service, 'Service', _client.service ?? '—'),
                    _InfoItem(Symbols.manage_accounts, 'Assigned To', _client.assignTo ?? '—'),
                  ]),

                  const SizedBox(height: 20),

                  // Dates section
                  _sectionTitle('Timeline'),
                  const SizedBox(height: 12),
                  _dateRow(Symbols.calendar_today, 'Joined', DateFormat('d MMM yyyy').format(_client.joinedDate), AppColors.primary),
                  _tappableDateRow(
                    context: context,
                    ref: ref,
                    client: _client,
                    icon: Symbols.event_repeat,
                    label: 'Contract Renewal',
                    date: _client.contractRenewal,
                    color: AppColors.primaryGlow,
                  ),

                  // Notes
                  if (_client.notes != null && _client.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _sectionTitle('Notes'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Text(_client.notes!, style: const TextStyle(color: AppColors.textMid, fontSize: 14, height: 1.5)),
                    ),
                  ],

                  const SizedBox(height: 20),
                  _ClientMeetingCard(client: _client),

                  const SizedBox(height: 20),
                  _sectionTitle('Activity History'),
                  const SizedBox(height: 12),
                  activitiesAsync.when(
                    data: (activities) => ActivityTimeline(
                      activities: activities,
                      onDelete: (a) { if (a.id != null) ref.read(logActivityProvider.notifier).deleteActivity(a.id!); },
                    ),
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))),
                    error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.danger)),
                  ),
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogActivitySheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  static Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: AppColors.textDark, size: 22),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: AppColors.textMid, fontSize: 11, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(children: [
      Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _infoGrid(List<_InfoItem> items) {
    return Column(
      children: List.generate((items.length / 2).ceil(), (row) {
        final a = items[row * 2];
        final b = row * 2 + 1 < items.length ? items[row * 2 + 1] : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Expanded(child: _infoCard(a)),
            const SizedBox(width: 10),
            Expanded(child: b != null ? _infoCard(b) : const SizedBox()),
          ]),
        );
      }),
    );
  }

  Widget _infoCard(_InfoItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, color: AppColors.primary, size: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.label, style: const TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(item.value, style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _dateRow(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }

  // ── Status change bottom sheet ──────────────────────────────────────────────
  void _showStatusSheet(BuildContext context) {
    const statuses = [
      ('Active',    AppColors.primary),
      ('VIP',       AppColors.primaryMid),
      ('Inactive',  AppColors.textLight),
      ('Completed', AppColors.primaryGlow),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 18),
            const Text('Change Client Status',
                style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Tap a status to update', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
            const SizedBox(height: 20),
            ...statuses.map((s) {
              final isActive = _client.status == s.$1;
              return GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  final updated = _client.copyWith(status: s.$1);
                  await ref.read(clientRepositoryProvider).updateClient(updated);
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: isActive ? s.$2.withValues(alpha: 0.10) : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isActive ? s.$2 : AppColors.border,
                        width: isActive ? 1.5 : 1),
                  ),
                  child: Row(children: [
                    Container(width: 10, height: 10,
                        decoration: BoxDecoration(color: s.$2, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Text(s.$1, style: TextStyle(
                        color: isActive ? s.$2 : AppColors.textDark,
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
                    const Spacer(),
                    if (isActive) Icon(Icons.check_circle_rounded, color: s.$2, size: 18),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Tappable date row for contract renewal ──────────────────────────────────
  Widget _tappableDateRow({
    required BuildContext context,
    required WidgetRef ref,
    required ClientModel client,
    required IconData icon,
    required String label,
    required DateTime? date,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? now.add(const Duration(days: 365)),
          firstDate: now.subtract(const Duration(days: 365)),
          lastDate: now.add(const Duration(days: 365 * 5)),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: AppColors.surface,
                onSurface: AppColors.textDark,
              ),
              dialogBackgroundColor: AppColors.surface,
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          final updated = client.copyWith(contractRenewal: picked);
          await ref.read(clientRepositoryProvider).updateClient(updated);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
            Text(
              date != null ? DateFormat('d MMM yyyy').format(date) : 'Tap to set date',
              style: TextStyle(
                  color: date != null ? color : AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontStyle: date == null ? FontStyle.italic : FontStyle.normal),
            ),
          ])),
          Icon(Icons.edit_calendar_outlined, color: AppColors.primary, size: 18),
        ]),
      ),
    );
  }

  void _showLogActivitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _LogSheet(leadId: _client.leadId, ref: ref),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label, value;
  const _InfoItem(this.icon, this.label, this.value);
}

// ── Log Activity Sheet ────────────────────────────────────────────────────────
class _LogSheet extends StatefulWidget {
  final String leadId;
  final WidgetRef ref;
  const _LogSheet({required this.leadId, required this.ref});
  @override
  State<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<_LogSheet> {
  ActivityType _type = ActivityType.call;
  final _outcomeCtrl = TextEditingController();
  final _notesCtrl   = TextEditingController();

  @override
  void dispose() { _outcomeCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const Text('Log Activity', style: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          const Text('Activity Type', style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: ActivityType.values.map((t) {
              final isSel = _type == t;
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primaryLight : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(t.icon, color: isSel ? AppColors.primary : AppColors.textMid, size: 16),
                    const SizedBox(width: 6),
                    Text(t.label, style: TextStyle(color: isSel ? AppColors.primary : AppColors.textMid, fontSize: 13, fontWeight: isSel ? FontWeight.w700 : FontWeight.normal)),
                  ]),
                ),
              );
            }).toList()),
          ),
          const SizedBox(height: 14),
          const Text('Outcome / Summary', style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _field(_outcomeCtrl, 'e.g. Client needs follow-up next week'),
          const SizedBox(height: 12),
          const Text('Notes (optional)', style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _field(_notesCtrl, 'Any extra details...', maxLines: 3),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]),
              child: ElevatedButton(
                onPressed: () async {
                  await widget.ref.read(logActivityProvider.notifier).logActivity(leadId: widget.leadId, type: _type, outcome: _outcomeCtrl.text.trim().isEmpty ? null : _outcomeCtrl.text.trim(), notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim());
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Save Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl, maxLines: maxLines,
      style: const TextStyle(color: AppColors.textDark, fontSize: 14),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meeting Check-In Card  (Client detail — salesperson side)
// ─────────────────────────────────────────────────────────────────────────────
class _ClientMeetingCard extends ConsumerWidget {
  final ClientModel client;
  const _ClientMeetingCard({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(meetingSessionProvider);
    final historyAsync =
        ref.watch(clientMeetingHistoryProvider(client.id ?? ''));
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final active = sessionState.activeSession;
    final isThisClient = active?.clientId == client.id;
    final inOtherMeeting = active != null && !isThisClient;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main check-in card ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isThisClient
                    ? AppColors.success.withValues(alpha: 0.45)
                    : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isThisClient
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Symbols.location_on,
                        size: 18,
                        color: isThisClient
                            ? AppColors.success
                            : AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Meeting Check-In',
                          style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      Text(
                        isThisClient
                            ? '🟢 In progress — manager can see your location'
                            : inOtherMeeting
                                ? '⚠️ Already in a meeting for another contact'
                                : 'Share your live location when meeting starts',
                        style: const TextStyle(
                            color: AppColors.textMid, fontSize: 11),
                      ),
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),

                if (sessionState.isLoading)
                  const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2),
                    ),
                  )
                else ...[
                  if (sessionState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(sessionState.error!,
                          style: const TextStyle(
                              color: AppColors.danger, fontSize: 11)),
                    ),

                  if (active == null)
                    _MeetingActionButton(
                      label: 'Start Meeting',
                      icon: Symbols.play_circle,
                      color: AppColors.success,
                      onTap: () async {
                        final err = await ref
                            .read(meetingSessionProvider.notifier)
                            .startMeeting(
                              userId: user.uid,
                              workerName: user.displayName ??
                                  user.email ??
                                  'Salesperson',
                              leadId: client.leadId,
                              leadName: client.name,
                              sourceType: 'client',
                              clientId: client.id,
                            );
                        if (err != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(err),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating));
                        }
                      },
                    )
                  else if (isThisClient)
                    _MeetingActionButton(
                      label: 'End Meeting',
                      icon: Symbols.stop_circle,
                      color: AppColors.danger,
                      onTap: () async {
                        final err = await ref
                            .read(meetingSessionProvider.notifier)
                            .endMeeting();
                        if (err != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(err),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating));
                        }
                      },
                    ),
                ],
              ],
            ),
          ),

          // ── Meeting history for this client ───────────────────────────
          if (client.id != null) ...[
            const SizedBox(height: 16),
            _ClientMeetingHistory(historyAsync: historyAsync),
          ],
        ],
      ),
    );
  }
}

// ── Reusable button widget ────────────────────────────────────────────────────
class _MeetingActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MeetingActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ── Compact meeting history list shown under the card ─────────────────────────
class _ClientMeetingHistory extends StatelessWidget {
  final AsyncValue<List<MeetingSessionModel>> historyAsync;
  const _ClientMeetingHistory({required this.historyAsync});

  static final _dateFmt = DateFormat('d MMM yyyy');
  static final _timeFmt = DateFormat('hh:mm a');

  @override
  Widget build(BuildContext context) {
    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meeting History (${sessions.length})',
                style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...sessions.map((s) => _HistoryTile(session: s,
                dateFmt: _dateFmt, timeFmt: _timeFmt)),
          ],
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final MeetingSessionModel session;
  final DateFormat dateFmt;
  final DateFormat timeFmt;
  const _HistoryTile(
      {required this.session,
      required this.dateFmt,
      required this.timeFmt});

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
    final hasLoc = session.lat != null && session.lng != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: session.isActive
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(children: [
        // Status dot
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: session.isActive
                ? AppColors.success
                : AppColors.primaryMid,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${dateFmt.format(session.startTime)}  •  ${timeFmt.format(session.startTime)}',
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              session.isActive
                  ? 'Ongoing • ${session.workerName}'
                  : 'Duration: ${session.durationLabel} • ${session.workerName}',
              style: const TextStyle(
                  color: AppColors.textMid, fontSize: 11),
            ),
          ]),
        ),
        if (hasLoc)
          GestureDetector(
            onTap: _openMap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(children: [
                Icon(Icons.location_on, color: Colors.white, size: 11),
                SizedBox(width: 4),
                Text('Map',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          )
        else
          const Icon(Icons.location_off_rounded,
              size: 16, color: AppColors.textLight),
      ]),
    );
  }
}
