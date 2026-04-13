import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/widgets/activity_timeline.dart';
import 'package:crm/models/activity_model.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/viewmodels/activity_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDetailPage extends ConsumerWidget {
  final ClientModel client;
  const ClientDetailPage({super.key, required this.client});

  Color _statusColor(String s) {
    switch (s) {
      case ClientStatus.vip:       return AppColors.primaryMid;
      case ClientStatus.active:    return AppColors.primary;
      case ClientStatus.inactive:  return AppColors.textLight;
      default:                     return AppColors.primaryGlow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesProvider(client.leadId));
    final statusColor = _statusColor(client.status);

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
                          child: Text(client.name[0].toUpperCase(),
                              style: const TextStyle(color: AppColors.textDark, fontSize: 36, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(client.name, style: const TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.w800)),
                      if (client.companyName != null) ...[
                        const SizedBox(height: 4),
                        Text(client.companyName!, style: TextStyle(color: AppColors.textMid, fontSize: 13)),
                      ],
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
                        ),
                        child: Text(client.status, style: TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 20),
                      // Action buttons
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _actionBtn(Icons.call_rounded, 'Call', () async {
                          final uri = Uri.parse('tel:${client.phone.replaceAll(RegExp(r'[\s\-()]'), '')}');
                          if (await canLaunchUrl(uri)) launchUrl(uri);
                        }),
                        const SizedBox(width: 16),
                        _actionBtn(Icons.chat_rounded, 'WhatsApp', () async {
                          final uri = Uri.parse('https://wa.me/${client.phone.replaceAll(RegExp(r'[\s\-+()]'), '')}');
                          if (await canLaunchUrl(uri)) launchUrl(uri);
                        }),
                        const SizedBox(width: 16),
                        _actionBtn(Icons.mail_rounded, 'Email', () async {
                          if (client.email != null) {
                            final uri = Uri.parse('mailto:${client.email}');
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
                  if (client.monthlyValue != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Monthly Value', style: TextStyle(color: AppColors.textMid, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('₹${client.monthlyValue!.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppColors.textDark, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                        ])),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Symbols.currency_rupee, color: AppColors.textDark, size: 26),
                        ),
                      ]),
                    ),

                  // Contact Details section
                  _sectionTitle('Contact Details'),
                  const SizedBox(height: 12),
                  _infoGrid([
                    _InfoItem(Symbols.mail, 'Email', client.email ?? '—'),
                    _InfoItem(Symbols.call, 'Phone', client.phone),
                    _InfoItem(Symbols.location_city, 'City', client.city ?? '—'),
                    _InfoItem(Symbols.business, 'Company', client.companyName ?? '—'),
                    _InfoItem(Symbols.home_repair_service, 'Service', client.service ?? '—'),
                    _InfoItem(Symbols.manage_accounts, 'Assigned To', client.assignTo ?? '—'),
                  ]),

                  const SizedBox(height: 20),

                  // Dates section
                  _sectionTitle('Timeline'),
                  const SizedBox(height: 12),
                  _dateRow(Symbols.calendar_today, 'Joined', DateFormat('d MMM yyyy').format(client.joinedDate), AppColors.primary),
                  if (client.contractRenewal != null)
                    _dateRow(Symbols.event_repeat, 'Contract Renewal', DateFormat('d MMM yyyy').format(client.contractRenewal!), AppColors.primarySoft),

                  // Notes
                  if (client.notes != null && client.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _sectionTitle('Notes'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(client.notes!, style: const TextStyle(color: AppColors.textMid, fontSize: 14, height: 1.5)),
                    ),
                  ],

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
        onPressed: () => _showLogActivitySheet(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Activity', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
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

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(color: AppColors.textDark, fontSize: 17, fontWeight: FontWeight.w700));

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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }

  void _showLogActivitySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _LogSheet(leadId: client.leadId, ref: ref),
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
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))]),
              child: ElevatedButton(
                onPressed: () async {
                  await widget.ref.read(logActivityProvider.notifier).logActivity(leadId: widget.leadId, type: _type, outcome: _outcomeCtrl.text.trim().isEmpty ? null : _outcomeCtrl.text.trim(), notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim());
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Save Activity', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 15)),
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
