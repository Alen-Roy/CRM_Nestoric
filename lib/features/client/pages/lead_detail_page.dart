import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/client/pages/edit_lead_page.dart';
import 'package:crm/core/widgets/activity_timeline.dart';
import 'package:crm/models/activity_model.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/models/meeting_session_model.dart';
import 'package:crm/viewmodels/activity_viewmodel.dart';
import 'package:crm/viewmodels/lead_detail_viewmodel.dart';
import 'package:crm/viewmodels/meeting_session_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    // Restore any active meeting session for this user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        ref.read(meetingSessionProvider.notifier).loadActiveSession(uid);
      }
    });
  }

  Color _stageColor(String stage) {
    switch (stage) {
      case 'New':
        return AppColors.primaryGlow;
      case 'Proposal':
        return AppColors.primarySoft;
      case 'Negotiation':
        return AppColors.primary;
      case 'Won':
        return AppColors.primary;
      case 'Lost':
        return AppColors.danger;
      default:
        return AppColors.textLight;
    }
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'High':
        return AppColors.danger;
      case 'Medium':
        return AppColors.primarySoft;
      case 'Low':
        return AppColors.primary;
      default:
        return AppColors.textLight;
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
          SnackBar(
            content: Text('Moved to $newStage'),
            behavior: SnackBarBehavior.floating,
          ),
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
              colors: [AppColors.textDark, AppColors.primaryGlow],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy with glow
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
                ),
                child: const Center(child: Icon(Icons.emoji_events_rounded, color: Colors.white, size: 48)),
              ),
              const SizedBox(height: 20),
              const Text('Deal Won!',
                  style: TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text(
                '${_lead.name} has been moved to Clients.',
                style: const TextStyle(color: AppColors.textMid, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                  ),
                  child: TextButton(
                    onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
                    child: const Text('View Clients →',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Lead?',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'This will permanently delete the lead and all its data.',
          style: TextStyle(color: AppColors.textMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMid),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(leadDetailProvider.notifier).deleteLead(_lead.id!);
              if (mounted) Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stageAsync = ref.watch(leadDetailProvider);
    final activitiesAsync = ref.watch(activitiesProvider(_lead.id ?? ''));

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogActivitySheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: _stageColor(_lead.stage),
            leading: IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 16),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (stageAsync.isLoading)
                const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.textDark, strokeWidth: 2))),
              // Edit button
              IconButton(
                icon: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 17),
                ),
                onPressed: () async {
                  final updated = await Navigator.push<LeadModel>(
                    context,
                    MaterialPageRoute(builder: (_) => EditLeadPage(lead: _lead)),
                  );
                  if (updated != null && mounted) setState(() => _lead = updated);
                },
              ),
              IconButton(
                icon: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.delete_outline, color: AppColors.textDark, size: 18),
                ),
                onPressed: _lead.id != null ? _confirmDelete : null,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_stageColor(_lead.stage), _stageColor(_lead.stage).withOpacity(0.7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(_lead.name[0].toUpperCase(), style: const TextStyle(color: AppColors.textDark, fontSize: 24, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(_lead.name, style: const TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w800)),
                            if (_lead.companyName != null)
                              Text(_lead.companyName!, style: TextStyle(color: AppColors.textMid, fontSize: 13)),
                          ])),
                          Column(children: [
                            _contactCircle(Symbols.call, AppColors.textDark),
                            const SizedBox(height: 8),
                            _contactCircle(Symbols.mail, AppColors.textDark),
                          ]),
                        ]),
                        const SizedBox(height: 14),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                            child: Text(_lead.stage, style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                          if (_lead.amount != null && _lead.amount!.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                              child: Text('₹${_lead.amount}', style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

            if (_lead.stage != 'Lost') ...[
              _sectionTitle('Pipeline Stage'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StagePipeline(
                  currentStage: _lead.stage,
                  onStageSelected: _moveStage,
                  stageColor: _stageColor,
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_lead.stage != 'Won' && _lead.stage != 'Lost')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => _moveStage('Lost'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.danger.withOpacity(0.35)),
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.close_rounded, color: AppColors.danger, size: 16),
                      SizedBox(width: 8),
                      Text('Mark as Lost', style: TextStyle(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            _sectionTitle('Company Details'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _infoGroup([
                _infoRow(Symbols.business, _lead.companyName ?? '—', 'Company Name'),
                _infoRow(Symbols.person, _lead.contactPerson ?? '—', 'Contact Person'),
                _infoRow(Symbols.location_city, _lead.city ?? '—', 'City'),
                _infoRow(Symbols.call, _lead.phone, 'Phone'),
                _infoRow(Symbols.mail, _lead.email ?? '—', 'Email'),
              ]),
            ),

            const SizedBox(height: 20),
            _sectionTitle('Service Details'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _infoGroup([
                _infoRow(Symbols.home_repair_service, _lead.service ?? '—', 'Service Interested In'),
                _infoRow(Symbols.currency_rupee, _lead.amount ?? '—', 'Estimated Value'),
                _infoRow(Symbols.manage_accounts, _lead.assignTo ?? '—', 'Assigned To'),
              ]),
            ),

            const SizedBox(height: 20),
            _sectionTitle('Lead Source'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _infoGroup([
                _infoRow(Symbols.travel_explore, _lead.leadSource ?? '—', 'Source'),
              ]),
            ),

            const SizedBox(height: 20),
            _sectionTitle('Priority & Notes'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _infoGroup([
                    _infoRow(Symbols.flag, _lead.priority ?? '—', 'Lead Priority',
                        valueColor: _priorityColor(_lead.priority)),
                  ]),
                  const SizedBox(height: 10),
                  _EditableNotesCard(
                    lead: _lead,
                    onSaved: (updated) => setState(() => _lead = updated),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _MeetingLocationCard(lead: _lead),

            const SizedBox(height: 20),
            _sectionTitle('Activity History'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: activitiesAsync.when(
                data: (activities) => ActivityTimeline(
                  activities: activities,
                  onDelete: (activity) {
                    if (activity.id != null)
                      ref
                          .read(logActivityProvider.notifier)
                          .deleteActivity(activity.id!);
                  },
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (e, _) => Text(
                  'Error: $e',
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            ),

            const SizedBox(height: 110),
          ],
          ),
        ),
        ],
      ),
    );
  }

  Widget _contactCircle(IconData icon, Color color) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 12),
      child: Row(children: [
        Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  // Single info row — used inside _infoGroup
  Widget _infoCard(IconData icon, String value, String label, {Color? valueColor}) {
    return _infoRow(icon, value, label, valueColor: valueColor);
  }

  Widget _infoRow(IconData icon, String value, String label, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(color: valueColor ?? AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
  }

  // Grouped card that wraps multiple rows in a single surface with dividers
  Widget _infoGroup(List<Widget> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          return Column(children: [
            e.value,
            if (!isLast) const Divider(height: 1, thickness: 1, color: AppColors.divider, indent: 64, endIndent: 16),
          ]);
        }).toList(),
      ),
    );
  }
}

// ── Stage Pipeline ────────────────────────────────────────────────────────────
class _StagePipeline extends StatelessWidget {
  final String currentStage;
  final void Function(String) onStageSelected;
  final Color Function(String) stageColor;

  const _StagePipeline({
    required this.currentStage,
    required this.onStageSelected,
    required this.stageColor,
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
          BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // ── Stage dots row ────────────────────────────────────────────
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
                          // Dot + bar
                          Row(children: [
                            Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                color: (isPast || isCurrent) ? color : AppColors.border,
                                shape: BoxShape.circle,
                                boxShadow: isCurrent ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)] : [],
                              ),
                            ),
                            if (!isLast)
                              Expanded(child: Container(height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: isPast ? [color, stageColor(stages[index+1])] : [AppColors.border, AppColors.border]),
                                  ))),
                          ]),
                          const SizedBox(height: 8),
                          Text(stage,
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
          const SizedBox(height: 18),
          if (currentStage != 'Won') ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6))],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final next = nextStage(currentStage);
                    if (next != null) onStageSelected(next);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    moveButtonLabel(currentStage),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary),
              ),
              child: const Center(
                child: Text(
                  'Deal Won — Client Created',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
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
  void dispose() { _outcomeController.dispose(); _notesController.dispose(); super.dispose(); }

  Color _typeAccent(ActivityType t) {
    switch (t) {
      case ActivityType.call:     return AppColors.primary;
      case ActivityType.meeting:  return AppColors.primaryGlow;
      case ActivityType.email:    return AppColors.danger;
      case ActivityType.proposal: return AppColors.primary;
      case ActivityType.note:     return AppColors.primarySoft;
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
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Log Activity',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Activity Type',
              style: TextStyle(
                color: AppColors.textMid,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
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
                        color: isSel ? accent.withOpacity(0.12) : AppColors.background,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: isSel ? accent : AppColors.border, width: isSel ? 1.5 : 1),
                        boxShadow: isSel ? [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 8, offset: const Offset(0,3))] : [],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(type.icon, color: isSel ? accent : AppColors.textMid, size: 16),
                        const SizedBox(width: 6),
                        Text(type.label, style: TextStyle(
                          color: isSel ? accent : AppColors.textMid,
                          fontSize: 13, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        )),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Outcome / Summary',
              style: TextStyle(
                color: AppColors.textMid,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            _lightTextField(
              _outcomeController,
              'e.g. Client is interested, follow up Monday',
            ),
            const SizedBox(height: 12),
            const Text(
              'Additional Notes (optional)',
              style: TextStyle(
                color: AppColors.textMid,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            _lightTextField(
              _notesController,
              'Any extra details...',
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.ref
                        .read(logActivityProvider.notifier)
                        .logActivity(
                          leadId: widget.leadId,
                          type: _selectedType,
                          outcome: _outcomeController.text.trim().isEmpty
                              ? null
                              : _outcomeController.text.trim(),
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Activity',
                    style: TextStyle(
                      color: AppColors.textDark,
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
    );
  }

  Widget _lightTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}

// ── Editable Notes Card ───────────────────────────────────────────────────────
class _EditableNotesCard extends ConsumerStatefulWidget {
  final LeadModel lead;
  final void Function(LeadModel updated) onSaved;
  const _EditableNotesCard({required this.lead, required this.onSaved});

  @override
  ConsumerState<_EditableNotesCard> createState() => _EditableNotesCardState();
}

class _EditableNotesCardState extends ConsumerState<_EditableNotesCard> {
  bool _editing = false;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.lead.notes ?? '');
  }

  @override
  void didUpdateWidget(_EditableNotesCard old) {
    super.didUpdateWidget(old);
    if (!_editing && old.lead.notes != widget.lead.notes) {
      _ctrl.text = widget.lead.notes ?? '';
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final newNotes = _ctrl.text.trim();
    await ref.read(leadDetailProvider.notifier).updateNotes(widget.lead, newNotes);
    setState(() => _editing = false);
    widget.onSaved(widget.lead.copyWith(notes: newNotes.isEmpty ? null : newNotes));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _editing ? AppColors.primary : AppColors.border, width: _editing ? 1.5 : 1),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with edit / save / cancel buttons
          Row(children: [
            const Text('Notes',
                style: TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w700)),
            const Spacer(),
            if (!_editing)
              GestureDetector(
                onTap: () => setState(() => _editing = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.edit_outlined, color: AppColors.primary, size: 13),
                    SizedBox(width: 4),
                    Text('Edit', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                  ]),
                ),
              )
            else ...[
              GestureDetector(
                onTap: () { setState(() => _editing = false); _ctrl.text = widget.lead.notes ?? ''; },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMid, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 10),

          // Content — static text OR text field
          if (!_editing)
            Text(
              widget.lead.notes?.isEmpty ?? true ? 'Tap Edit to add notes...' : widget.lead.notes!,
              style: TextStyle(
                color: (widget.lead.notes == null || widget.lead.notes!.isEmpty)
                    ? AppColors.textLight
                    : AppColors.textMid,
                fontSize: 13,
                height: 1.55,
                fontStyle: (widget.lead.notes == null || widget.lead.notes!.isEmpty)
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            )
          else
            TextField(
              controller: _ctrl,
              maxLines: 5,
              autofocus: true,
              style: const TextStyle(color: AppColors.textDark, fontSize: 13, height: 1.55),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Add notes about this lead...',
                hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meeting Location Card  (Salesperson side)
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// Meeting Location Card  (Salesperson — Lead side)
// ─────────────────────────────────────────────────────────────────────────────
class _MeetingLocationCard extends ConsumerWidget {
  final LeadModel lead;
  const _MeetingLocationCard({required this.lead});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(meetingSessionProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final active      = sessionState.activeSession;
    final isThisLead  = active?.leadId == lead.id;
    final inOther     = active != null && !isThisLead;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Check-in card ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isThisLead
                    ? AppColors.success.withValues(alpha: 0.5)
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
                // ── Header ─────────────────────────────────────────────
                Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isThisLead
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Symbols.location_on,
                      size: 18,
                      color: isThisLead
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Meeting Check-In',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          isThisLead
                              ? '🟢 Meeting in progress — manager can see your location'
                              : inOther
                                  ? '⚠️ You are already in a meeting for another lead'
                                  : 'Share your live location when meeting starts',
                          style: const TextStyle(
                              color: AppColors.textMid, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 14),

                // ── Loading ─────────────────────────────────────────────
                if (sessionState.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2),
                      ),
                    ),
                  )
                else ...[
                  // ── Error ────────────────────────────────────────────
                  if (sessionState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        sessionState.error!,
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 11),
                      ),
                    ),

                  // ── Start button ──────────────────────────────────────
                  if (active == null)
                    _MeetingButton(
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
                              leadId: lead.id ?? '',
                              leadName: lead.name,
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

                  // ── End button (this lead only) ───────────────────────
                  else if (isThisLead)
                    _MeetingButton(
                      label: 'End Meeting',
                      icon: Symbols.stop_circle,
                      color: AppColors.danger,
                      onTap: () async {
                        final err = await ref
                            .read(meetingSessionProvider.notifier)
                            .endMeeting();
                        if (err != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(err),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      },
                    ),
                ],
              ],
            ),
          ),

          // ── Meeting history for this lead ──────────────────────────
          if (lead.id != null) ...[
            const SizedBox(height: 12),
            _LeadMeetingHistory(leadId: lead.id!),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable meeting button
// ─────────────────────────────────────────────────────────────────────────────
class _MeetingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MeetingButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

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
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lead Meeting History  (compact, inside the check-in card section)
// ─────────────────────────────────────────────────────────────────────────────
class _LeadMeetingHistory extends ConsumerWidget {
  final String leadId;
  const _LeadMeetingHistory({required this.leadId});

  static final _dateFmt = DateFormat('d MMM yyyy');
  static final _timeFmt = DateFormat('hh:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(leadMeetingHistoryProvider(leadId));

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.history_rounded,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Meeting History (${sessions.length})',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              ...sessions.asMap().entries.map((e) {
                final isLast = e.key == sessions.length - 1;
                return Column(
                  children: [
                    _LeadHistoryTile(
                      session: e.value,
                      dateFmt: _dateFmt,
                      timeFmt: _timeFmt,
                    ),
                    if (!isLast)
                      const Divider(
                          height: 12,
                          thickness: 1,
                          color: AppColors.divider),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual history tile
// ─────────────────────────────────────────────────────────────────────────────
class _LeadHistoryTile extends StatelessWidget {
  final MeetingSessionModel session;
  final DateFormat dateFmt;
  final DateFormat timeFmt;
  const _LeadHistoryTile({
    required this.session,
    required this.dateFmt,
    required this.timeFmt,
  });

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status dot
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: session.isActive
                  ? AppColors.success
                  : AppColors.primaryMid,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),

          // Date + duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dateFmt.format(session.startTime)}  •  '
                  '${timeFmt.format(session.startTime)}',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  session.isActive
                      ? 'Ongoing'
                      : 'Duration: ${session.durationLabel}',
                  style: const TextStyle(
                      color: AppColors.textMid, fontSize: 11),
                ),
              ],
            ),
          ),

          // Map button / no-GPS icon
          if (hasLoc)
            GestureDetector(
              onTap: _openMap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
            const Tooltip(
              message: 'No GPS recorded',
              child: Icon(Icons.location_off_rounded,
                  size: 15, color: AppColors.textLight),
            ),
        ],
      ),
    );
  }
}
