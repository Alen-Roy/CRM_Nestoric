import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/widgets/activity_timeline.dart';
import 'package:crm/models/activity_model.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/viewmodels/activity_viewmodel.dart';
import 'package:crm/viewmodels/lead_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

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
      case 'New':         return AppColors.secondary;
      case 'Proposal':    return AppColors.warning;
      case 'Negotiation': return AppColors.primary;
      case 'Won':         return AppColors.success;
      case 'Lost':        return AppColors.danger;
      default:            return AppColors.textLight;
    }
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'High':   return AppColors.danger;
      case 'Medium': return AppColors.warning;
      case 'Low':    return AppColors.success;
      default:       return AppColors.textLight;
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
          const SnackBar(content: Text('Lead marked as Lost'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text('Deal Won!', style: TextStyle(color: AppColors.success, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('${_lead.name} has been moved to Clients.', style: const TextStyle(color: AppColors.textMid, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: const Text('View Clients →', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showLogActivitySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LeadLogActivitySheet(lead: _lead, ref: ref),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Lead?', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        content: const Text('This will permanently delete the lead and all its data.', style: TextStyle(color: AppColors.textMid)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textMid))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(leadDetailProvider.notifier).deleteLead(_lead.id!);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Lead Details', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          if (stageAsync.isLoading)
            const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textLight),
            onPressed: _lead.id != null ? _confirmDelete : null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogActivitySheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero header ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.subtleGradient,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(_lead.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_lead.name, style: const TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w800)),
                        if (_lead.companyName != null)
                          Text(_lead.companyName!, style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _stageColor(_lead.stage).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(_lead.stage, style: TextStyle(color: _stageColor(_lead.stage), fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                            if (_lead.amount != null) ...[
                              const SizedBox(width: 10),
                              Text('₹${_lead.amount}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 15)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _contactCircle(Symbols.call, AppColors.success),
                      const SizedBox(height: 8),
                      _contactCircle(Symbols.mail, AppColors.secondary),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_lead.stage != 'Lost') ...[
              _sectionTitle('🚀 Pipeline Stage'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StagePipeline(currentStage: _lead.stage, onStageSelected: _moveStage, stageColor: _stageColor),
              ),
              const SizedBox(height: 16),
            ],

            if (_lead.stage != 'Won' && _lead.stage != 'Lost')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton.icon(
                  onPressed: () => _moveStage('Lost'),
                  icon: const Icon(Icons.close, color: AppColors.danger, size: 16),
                  label: const Text('Mark as Lost', style: TextStyle(color: AppColors.danger)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            _sectionTitle('🏢 Company Details'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _infoCard(Symbols.business, _lead.companyName ?? '—', 'Company Name'),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.person, _lead.contactPerson ?? '—', 'Contact Person'),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.location_city, _lead.city ?? '—', 'City'),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.call, _lead.phone, 'Phone'),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.mail, _lead.email ?? '—', 'Email'),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('📦 Service Details'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _infoCard(Symbols.home_repair_service, _lead.service ?? '—', 'Service Interested In'),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.currency_rupee, _lead.amount ?? '—', 'Estimated Value'),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.manage_accounts, _lead.assignTo ?? '—', 'Assigned To'),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('📡 Lead Source'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _infoCard(Symbols.travel_explore, _lead.leadSource ?? '—', 'Source'),
            ),

            const SizedBox(height: 20),
            _sectionTitle('⚡ Priority & Notes'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _infoCard(Symbols.flag, _lead.priority ?? '—', 'Lead Priority', valueColor: _priorityColor(_lead.priority)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notes', style: TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(_lead.notes ?? 'No notes available.', style: const TextStyle(color: AppColors.textMid, fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('📋 Activity History'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: activitiesAsync.when(
                data: (activities) => ActivityTimeline(
                  activities: activities,
                  onDelete: (activity) {
                    if (activity.id != null) ref.read(logActivityProvider.notifier).deleteActivity(activity.id!);
                  },
                ),
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))),
                error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.danger)),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _contactCircle(IconData icon, Color color) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withOpacity(0.12),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 10),
      child: Text(title, style: const TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }

  Widget _infoCard(IconData icon, String value, String label, {Color? valueColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: valueColor ?? AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stage Pipeline ────────────────────────────────────────────────────────────
class _StagePipeline extends StatelessWidget {
  final String currentStage;
  final void Function(String) onStageSelected;
  final Color Function(String) stageColor;

  const _StagePipeline({required this.currentStage, required this.onStageSelected, required this.stageColor});

  @override
  Widget build(BuildContext context) {
    const stages = ['New', 'Proposal', 'Negotiation', 'Won'];
    final currentIndex = stages.indexOf(currentStage);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
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
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: (isPast || isCurrent) ? color : AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stage,
                            style: TextStyle(
                              color: isCurrent ? color : AppColors.textLight,
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (!isLast) const SizedBox(width: 4),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (currentStage != 'Won') ...[
            SizedBox(
              width: double.infinity,
              height: 46,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final next = nextStage(currentStage);
                    if (next != null) onStageSelected(next);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(moveButtonLabel(currentStage), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success),
              ),
              child: const Center(
                child: Text('🏆 Deal Won — Client Created', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 14)),
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
  final LeadModel lead;
  final WidgetRef ref;
  const _LeadLogActivitySheet({required this.lead, required this.ref});

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Log Activity', style: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text('Activity Type', style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ActivityType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(type.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(type.label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textMid, fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Outcome / Summary', style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _lightTextField(_outcomeController, 'e.g. Client is interested, follow up Monday'),
            const SizedBox(height: 12),
            const Text('Additional Notes (optional)', style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _lightTextField(_notesController, 'Any extra details...', maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.ref.read(logActivityProvider.notifier).logActivity(
                      lead: widget.lead,
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
                  child: const Text('Save Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
