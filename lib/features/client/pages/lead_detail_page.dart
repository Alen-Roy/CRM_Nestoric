import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/widgets/activity_timeline.dart';
import 'package:crm/models/activity_model.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/viewmodels/activity_viewmodel.dart';
import 'package:crm/viewmodels/lead_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadDetailPage extends ConsumerStatefulWidget {
  final LeadModel lead;
  const LeadDetailPage({super.key, required this.lead});

  @override
  ConsumerState<LeadDetailPage> createState() => _LeadDetailPageState();
}

class _LeadDetailPageState extends ConsumerState<LeadDetailPage> {
  late LeadModel _lead;

  @override
  void initState() {
    super.initState();
    _lead = widget.lead;
  }

  Color _stageColor(String stage) {
    switch (stage) {
      case 'New':        return AppColors.primaryGlow;
      case 'Proposal':   return AppColors.primary;
      case 'Negotiation':return const Color(0xFFFF8F00);
      case 'Won':        return AppColors.success;
      case 'Lost':       return AppColors.danger;
      default:           return AppColors.textLight;
    }
  }

  IconData _stageIcon(String stage) {
    switch (stage) {
      case 'New':        return Icons.fiber_new_rounded;
      case 'Proposal':   return Icons.description_rounded;
      case 'Negotiation':return Icons.handshake_rounded;
      case 'Won':        return Icons.emoji_events_rounded;
      case 'Lost':       return Icons.cancel_rounded;
      default:           return Icons.circle;
    }
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'High':   return AppColors.danger;
      case 'Medium': return const Color(0xFFFF8F00);
      case 'Low':    return AppColors.success;
      default:       return AppColors.textLight;
    }
  }

  IconData _priorityIcon(String? priority) {
    switch (priority) {
      case 'High':   return Icons.flag_rounded;
      case 'Medium': return Icons.flag_outlined;
      case 'Low':    return Icons.outlined_flag_rounded;
      default:       return Icons.flag_rounded;
    }
  }

  Future<void> _moveStage(String newStage) async {
    final notifier = ref.read(leadDetailProvider.notifier);
    final updated = await notifier.updateStage(_lead, newStage);
    if (updated != null && mounted) {
      setState(() => _lead = updated);
      if (newStage == 'Won') {
        _showWonCelebration();
      } else if (newStage == 'Lost') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lead marked as Lost'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Moved to $newStage'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _showWonCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A163A), Color(0xFF3A2F8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 50),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Deal Won! 🎉',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_lead.name} has been moved to Clients.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryGlow],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'View Clients →',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogActivitySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LeadLogActivitySheet(leadId: _lead.id ?? '', ref: ref),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.dangerLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_rounded, color: AppColors.danger, size: 26),
        ),
        title: const Text(
          'Delete Lead?',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'This will permanently delete the lead and all its data.',
          style: TextStyle(color: AppColors.textMid),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMid)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(leadDetailProvider.notifier).deleteLead(_lead.id!);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stageAsync = ref.watch(leadDetailProvider);
    final activitiesAsync = ref.watch(activitiesProvider(_lead.id ?? ''));
    final stageColor = _stageColor(_lead.stage);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogActivitySheet,
        backgroundColor: AppColors.primary,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Log Activity',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Hero SliverAppBar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            backgroundColor: stageColor,
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
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            actions: [
              if (stageAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
                child: GestureDetector(
                  onTap: _lead.id != null ? _confirmDelete : null,
                  child: Container(
                    width: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroHeader(stageColor),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Lead Value Card ──────────────────────────────────────
                  if (_lead.amount != null && _lead.amount!.isNotEmpty)
                    _buildLeadValueCard(),

                  const SizedBox(height: 20),

                  // ── Pipeline Stage ───────────────────────────────────────
                  if (_lead.stage != 'Lost') ...[
                    _sectionHeader('Pipeline Stage', Symbols.account_tree),
                    const SizedBox(height: 12),
                    _StagePipeline(
                      currentStage: _lead.stage,
                      onStageSelected: _moveStage,
                      stageColor: _stageColor,
                      stageIcon: _stageIcon,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Mark as Lost button ──────────────────────────────────
                  if (_lead.stage != 'Won' && _lead.stage != 'Lost')
                    _buildMarkAsLostBtn(),

                  const SizedBox(height: 24),

                  // ── Company Details ──────────────────────────────────────
                  _sectionHeader('Company Details', Symbols.business),
                  const SizedBox(height: 12),
                  _infoGroup([
                    _InfoRow(Symbols.business, _lead.companyName ?? '—', 'Company Name', AppColors.primary),
                    _InfoRow(Symbols.person, _lead.contactPerson ?? '—', 'Contact Person', AppColors.primaryGlow),
                    _InfoRow(Symbols.location_city, _lead.city ?? '—', 'City', const Color(0xFFFF8F00)),
                    _InfoRow(Symbols.call, _lead.phone, 'Phone', AppColors.success),
                    _InfoRow(Symbols.mail, _lead.email ?? '—', 'Email', AppColors.danger),
                  ]),

                  const SizedBox(height: 24),

                  // ── Service Details ──────────────────────────────────────
                  _sectionHeader('Service Details', Symbols.home_repair_service),
                  const SizedBox(height: 12),
                  _infoGroup([
                    _InfoRow(Symbols.home_repair_service, _lead.service ?? '—', 'Service Interested In', AppColors.primaryMid),
                    _InfoRow(Symbols.currency_rupee, _lead.amount ?? '—', 'Estimated Value', const Color(0xFFFF8F00)),
                    _InfoRow(Symbols.manage_accounts, _lead.assignTo ?? '—', 'Assigned To', AppColors.primary),
                  ]),

                  const SizedBox(height: 24),

                  // ── Lead Source & Priority ───────────────────────────────
                  _sectionHeader('Lead Details', Symbols.info),
                  const SizedBox(height: 12),
                  _buildLeadMetaCard(),

                  const SizedBox(height: 24),

                  // ── Notes ────────────────────────────────────────────────
                  _sectionHeader('Notes', Symbols.sticky_note_2),
                  const SizedBox(height: 12),
                  _buildNotesCard(),

                  const SizedBox(height: 24),

                  // ── Activity History ─────────────────────────────────────
                  _sectionHeader('Activity History', Symbols.history),
                  const SizedBox(height: 12),
                  activitiesAsync.when(
                    data: (activities) => ActivityTimeline(
                      activities: activities,
                      onDelete: (activity) {
                        if (activity.id != null) {
                          ref.read(logActivityProvider.notifier).deleteActivity(activity.id!);
                        }
                      },
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
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
    );
  }

  // ── Hero Header ───────────────────────────────────────────────────────────
  Widget _buildHeroHeader(Color stageColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            stageColor.withValues(alpha: 1.0),
            stageColor.withValues(alpha: 0.75),
            stageColor.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative blobs
          Positioned(
            top: -30, right: -20,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: -40,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 66, height: 66,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _lead.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _lead.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (_lead.companyName != null) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.business_rounded,
                                      color: Colors.white.withValues(alpha: 0.7), size: 13),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _lead.companyName!,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Contact buttons
                      Column(
                        children: [
                          _headerActionBtn(Symbols.call, () async {
                            final uri = Uri.parse('tel:${_lead.phone.replaceAll(RegExp(r'[\s\-()]'), '')}');
                            if (await canLaunchUrl(uri)) launchUrl(uri);
                          }),
                          const SizedBox(height: 8),
                          _headerActionBtn(Symbols.mail, () async {
                            if (_lead.email != null) {
                              final uri = Uri.parse('mailto:${_lead.email}');
                              if (await canLaunchUrl(uri)) launchUrl(uri);
                            }
                          }),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Bottom badges row
                  Row(
                    children: [
                      _headerBadge(_stageIcon(_lead.stage), _lead.stage),
                      const SizedBox(width: 8),
                      if (_lead.priority != null && _lead.priority!.isNotEmpty)
                        _headerBadge(
                          _priorityIcon(_lead.priority),
                          '${_lead.priority} Priority',
                        ),
                      if (_lead.amount != null && _lead.amount!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _headerBadge(Symbols.currency_rupee, '₹${_lead.amount}'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerActionBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _headerBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Lead Value Card ───────────────────────────────────────────────────────
  Widget _buildLeadValueCard() {
    final stageColor = _stageColor(_lead.stage);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [stageColor, stageColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: stageColor.withValues(alpha: 0.35),
            blurRadius: 18,
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
                  'Estimated Value',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${_lead.amount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_stageIcon(_lead.stage), color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  // ── Mark as Lost ──────────────────────────────────────────────────────────
  Widget _buildMarkAsLostBtn() {
    return GestureDetector(
      onTap: () => _moveStage('Lost'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close_rounded, color: AppColors.danger, size: 18),
            SizedBox(width: 8),
            Text(
              'Mark as Lost',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Lead Meta Card (source + priority) ────────────────────────────────────
  Widget _buildLeadMetaCard() {
    final priorityColor = _priorityColor(_lead.priority);
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
          // Source row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Symbols.travel_explore, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lead Source',
                        style: TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _lead.leadSource ?? '—',
                        style: const TextStyle(
                          color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider, indent: 68, endIndent: 16),
          // Priority row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_priorityIcon(_lead.priority), color: priorityColor, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lead Priority',
                        style: TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _lead.priority ?? '—',
                        style: TextStyle(
                          color: priorityColor, fontSize: 13, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _lead.priority ?? '—',
                    style: TextStyle(
                      color: priorityColor, fontSize: 11, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              _lead.notes?.isNotEmpty == true ? _lead.notes! : 'No notes available.',
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

  // ── Info Row (inside grouped card) ────────────────────────────────────────
  Widget _infoGroup(List<_InfoRow> rows) {
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
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          final row = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: row.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(row.icon, color: row.color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.label,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            row.value,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1, thickness: 1, color: AppColors.divider,
                  indent: 68, endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Data class for info rows
class _InfoRow {
  final IconData icon;
  final String value, label;
  final Color color;
  const _InfoRow(this.icon, this.value, this.label, this.color);
}

// ── Stage Pipeline ────────────────────────────────────────────────────────────
class _StagePipeline extends StatelessWidget {
  final String currentStage;
  final void Function(String) onStageSelected;
  final Color Function(String) stageColor;
  final IconData Function(String) stageIcon;

  const _StagePipeline({
    required this.currentStage,
    required this.onStageSelected,
    required this.stageColor,
    required this.stageIcon,
  });

  @override
  Widget build(BuildContext context) {
    const stages = ['New', 'Proposal', 'Negotiation', 'Won'];
    final currentIndex = stages.indexOf(currentStage);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Stage progress bar ──────────────────────────────────────────
          Row(
            children: stages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final isPast = index < currentIndex;
              final isCurrent = index == currentIndex;
              final isLast = index == stages.length - 1;
              final color = stageColor(stage);

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isCurrent ? 16 : 12,
                                height: isCurrent ? 16 : 12,
                                decoration: BoxDecoration(
                                  color: (isPast || isCurrent) ? color : AppColors.border,
                                  shape: BoxShape.circle,
                                  boxShadow: isCurrent
                                      ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]
                                      : [],
                                ),
                                child: isCurrent
                                    ? Icon(stageIcon(stage), color: Colors.white, size: 8)
                                    : isPast
                                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 8)
                                        : null,
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isPast
                                            ? [color, stageColor(stages[index + 1])]
                                            : [
                                                AppColors.border,
                                                AppColors.border,
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stage,
                            style: TextStyle(
                              color: isCurrent ? color : AppColors.textLight,
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // ── Move to next stage button / Won state ───────────────────────
          if (currentStage != 'Won')
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final next = nextStage(currentStage);
                    if (next != null) onStageSelected(next);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  label: Text(
                    moveButtonLabel(currentStage),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_rounded, color: AppColors.success, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Deal Won — Client Created',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Log Activity bottom sheet ─────────────────────────────────────────────────
class _LeadLogActivitySheet extends StatefulWidget {
  final String leadId;
  final WidgetRef ref;
  const _LeadLogActivitySheet({required this.leadId, required this.ref});

  @override
  State<_LeadLogActivitySheet> createState() => _LeadLogActivitySheetState();
}

class _LeadLogActivitySheetState extends State<_LeadLogActivitySheet> {
  ActivityType _selectedType = ActivityType.call;
  final _outcomeController = TextEditingController();
  final _notesController   = TextEditingController();

  @override
  void dispose() {
    _outcomeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color _typeAccent(ActivityType t) {
    switch (t) {
      case ActivityType.call:     return AppColors.success;
      case ActivityType.meeting:  return AppColors.primaryGlow;
      case ActivityType.email:    return AppColors.danger;
      case ActivityType.proposal: return const Color(0xFFFF8F00);
      case ActivityType.note:     return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
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
            const SizedBox(height: 4),
            const Text(
              'Record a touchpoint with this lead',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
            const SizedBox(height: 18),
            const Text('Activity Type',
                style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ActivityType.values.map((type) {
                  final isSel = _selectedType == type;
                  final accent = _typeAccent(type);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel ? accent.withValues(alpha: 0.12) : AppColors.background,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSel ? accent : AppColors.border,
                          width: isSel ? 1.5 : 1,
                        ),
                        boxShadow: isSel
                            ? [BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
                            : [],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(type.icon, color: isSel ? accent : AppColors.textMid, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          type.label,
                          style: TextStyle(
                            color: isSel ? accent : AppColors.textMid,
                            fontSize: 13,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Outcome / Summary',
                style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _lightTextField(_outcomeController, 'e.g. Client is interested, follow up Monday'),
            const SizedBox(height: 12),
            const Text('Additional Notes (optional)',
                style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _lightTextField(_notesController, 'Any extra details...', maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
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
                      type: _selectedType,
                      outcome: _outcomeController.text.trim().isEmpty ? null : _outcomeController.text.trim(),
                      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    );
  }

  Widget _lightTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textDark, fontSize: 14),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        filled: true,
        fillColor: AppColors.background,
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
