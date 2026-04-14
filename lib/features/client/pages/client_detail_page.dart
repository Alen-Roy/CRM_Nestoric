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
      case ClientStatus.vip:
        return const Color(0xFFFF8F00); // amber for VIP
      case ClientStatus.active:
        return AppColors.success;
      case ClientStatus.inactive:
        return AppColors.textLight;
      default:
        return AppColors.primaryGlow;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case ClientStatus.vip:
        return Icons.star_rounded;
      case ClientStatus.active:
        return Icons.check_circle_rounded;
      case ClientStatus.inactive:
        return Icons.pause_circle_rounded;
      default:
        return Icons.circle;
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
          // ── Hero SliverAppBar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
                child: Container(
                  width: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5849D9), AppColors.primary, AppColors.primaryGlow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -40, right: -30,
                      child: Container(
                        width: 180, height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30, left: -50,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),

                          // Avatar with glow ring
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                                  child: Text(
                                    client.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(_statusIcon(client.status), color: Colors.white, size: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            client.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (client.companyName != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.business_rounded,
                                    color: Colors.white.withValues(alpha: 0.7), size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  client.companyName!,
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withValues(alpha: 0.6), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_statusIcon(client.status), color: Colors.white, size: 12),
                                const SizedBox(width: 5),
                                Text(
                                  client.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _actionBtn(
                                Icons.call_rounded, 'Call',
                                const Color(0xFF4CAF7D),
                                () async {
                                  final uri = Uri.parse(
                                      'tel:${client.phone.replaceAll(RegExp(r'[\s\-()]'), '')}');
                                  if (await canLaunchUrl(uri)) launchUrl(uri);
                                },
                              ),
                              const SizedBox(width: 16),
                              _actionBtn(
                                Icons.chat_rounded, 'WhatsApp',
                                const Color(0xFF25D366),
                                () async {
                                  final uri = Uri.parse(
                                      'https://wa.me/${client.phone.replaceAll(RegExp(r'[\s\-+()]'), '')}');
                                  if (await canLaunchUrl(uri)) launchUrl(uri);
                                },
                              ),
                              const SizedBox(width: 16),
                              _actionBtn(
                                Icons.mail_rounded, 'Email',
                                AppColors.primaryMid,
                                () async {
                                  if (client.email != null) {
                                    final uri = Uri.parse('mailto:${client.email}');
                                    if (await canLaunchUrl(uri)) launchUrl(uri);
                                  }
                                },
                              ),
                            ],         // closes Row children
                          ),           // closes Row
                        ],             // closes Column children
                      ),               // closes Column
                      ),               // closes SingleChildScrollView
                    ),                 // closes SafeArea
                  ],                   // closes Stack children
                ),                     // closes Stack
              ),                       // closes Container
            ),                         // closes FlexibleSpaceBar
          ),                           // closes SliverAppBar

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Monthly Value + Stats Row ──────────────────────────
                  if (client.monthlyValue != null)
                    _buildRevenueCard(),

                  const SizedBox(height: 20),

                  // ── Quick Stats ───────────────────────────────────────
                  _buildQuickStats(),

                  const SizedBox(height: 24),

                  // ── Contact Details ───────────────────────────────────
                  _sectionHeader('Contact Details', Symbols.contact_page),
                  const SizedBox(height: 12),
                  _buildContactCard(),

                  const SizedBox(height: 24),

                  // ── Timeline ──────────────────────────────────────────
                  _sectionHeader('Key Dates', Symbols.calendar_month),
                  const SizedBox(height: 12),
                  _buildDatesCard(),

                  // ── Notes ─────────────────────────────────────────────
                  if (client.notes != null && client.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionHeader('Notes', Symbols.sticky_note_2),
                    const SizedBox(height: 12),
                    _buildNotesCard(),
                  ],

                  const SizedBox(height: 24),

                  // ── Activity History ──────────────────────────────────
                  _sectionHeader('Activity History', Symbols.history),
                  const SizedBox(height: 12),
                  activitiesAsync.when(
                    data: (activities) => ActivityTimeline(
                      activities: activities,
                      onDelete: (a) {
                        if (a.id != null) {
                          ref.read(logActivityProvider.notifier).deleteActivity(a.id!);
                        }
                      },
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2,
                        ),
                      ),
                    ),
                    error: (e, _) => Text('Error: $e',
                        style: const TextStyle(color: AppColors.danger)),
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
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Log Activity',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── Revenue Card ─────────────────────────────────────────────────────────
  Widget _buildRevenueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5849D9), AppColors.primary, AppColors.primaryGlow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Value',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${_formatAmount(client.monthlyValue!)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up_rounded,
                          color: Colors.white.withValues(alpha: 0.9), size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Active Revenue',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Symbols.currency_rupee, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  // ── Quick Stats ───────────────────────────────────────────────────────────
  Widget _buildQuickStats() {
    final joined = DateFormat('MMM yyyy').format(client.joinedDate);
    final renewal = client.contractRenewal != null
        ? DateFormat('d MMM yy').format(client.contractRenewal!)
        : '—';

    return Row(
      children: [
        _statChip(Symbols.calendar_today, 'Since', joined, AppColors.primary),
        const SizedBox(width: 12),
        _statChip(Symbols.event_repeat, 'Renewal', renewal, const Color(0xFFFF8F00)),
        const SizedBox(width: 12),
        _statChip(
          Symbols.manage_accounts, 'Assigned',
          client.assignTo != null && client.assignTo!.isNotEmpty
              ? client.assignTo!.split(' ').first
              : '—',
          AppColors.primaryGlow,
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Contact Card ──────────────────────────────────────────────────────────
  Widget _buildContactCard() {
    final items = [
      _InfoItem(Symbols.mail, 'Email', client.email ?? '—', AppColors.danger),
      _InfoItem(Symbols.call, 'Phone', client.phone, AppColors.success),
      _InfoItem(Symbols.location_city, 'City', client.city ?? '—', AppColors.primaryGlow),
      _InfoItem(Symbols.business, 'Company', client.companyName ?? '—', AppColors.primary),
      _InfoItem(Symbols.home_repair_service, 'Service', client.service ?? '—', const Color(0xFFFF8F00)),
      _InfoItem(Symbols.manage_accounts, 'Assigned To', client.assignTo ?? '—', AppColors.primaryMid),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          final item = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.border,
                      size: 18,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.divider,
                  indent: 68,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Dates Card ────────────────────────────────────────────────────────────
  Widget _buildDatesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _dateRow(
            Symbols.calendar_today,
            'Client Since',
            DateFormat('d MMMM yyyy').format(client.joinedDate),
            AppColors.primary,
            isLast: client.contractRenewal == null,
          ),
          if (client.contractRenewal != null)
            _dateRow(
              Symbols.event_repeat,
              'Contract Renewal',
              DateFormat('d MMMM yyyy').format(client.contractRenewal!),
              const Color(0xFFFF8F00),
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _dateRow(IconData icon, String label, String value, Color color,
      {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.divider,
            indent: 68,
            endIndent: 16,
          ),
      ],
    );
  }

  // ── Notes Card ────────────────────────────────────────────────────────────
  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Symbols.sticky_note_2, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              client.notes!,
              style: const TextStyle(
                color: AppColors.textMid,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── Action Button ─────────────────────────────────────────────────────────
  static Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogActivitySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogSheet(leadId: client.leadId, ref: ref),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label, value;
  final Color color;
  const _InfoItem(this.icon, this.label, this.value, this.color);
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
  void dispose() {
    _outcomeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Log Activity',
                  style: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                const Text('Activity Type',
                    style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ActivityType.values.map((t) {
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
                            Text(t.label, style: TextStyle(
                              color: isSel ? AppColors.primary : AppColors.textMid,
                              fontSize: 13,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.normal,
                            )),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Outcome / Summary',
                    style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _field(_outcomeCtrl, 'e.g. Client needs follow-up next week'),
                const SizedBox(height: 12),
                const Text('Notes (optional)',
                    style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _field(_notesCtrl, 'Any extra details...', maxLines: 3),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await widget.ref.read(logActivityProvider.notifier).logActivity(
                          leadId: widget.leadId,
                          type: _type,
                          outcome: _outcomeCtrl.text.trim().isEmpty ? null : _outcomeCtrl.text.trim(),
                          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Save Activity',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl, maxLines: maxLines,
      style: const TextStyle(color: AppColors.textDark, fontSize: 14),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
