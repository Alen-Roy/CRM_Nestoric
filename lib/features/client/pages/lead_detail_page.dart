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
      case 'New':
        return const Color(0xFF96E1FF);
      case 'Proposal':
        return const Color(0xFFFFC97A);
      case 'Negotiation':
        return const Color(0xFFC56BFF);
      case 'Won':
        return const Color(0xFF67D39F);
      case 'Lost':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.amber;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
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
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved to $newStage'),
            backgroundColor: const Color(0xFF1E1E2E),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text(
              'Deal Won!',
              style: TextStyle(
                color: Color(0xFF67D39F),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_lead.name} has been moved to Clients.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'View Clients →',
              style: TextStyle(color: Color(0xFF67D39F)),
            ),
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
      builder: (ctx) => _LeadLogActivitySheet(
        leadId: _lead.id ?? '',
        ref: ref,
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Lead?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will permanently delete the lead and all its data.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(leadDetailProvider.notifier)
                  .deleteLead(_lead.id!);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lead Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (stageAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white54),
            onPressed: _lead.id != null ? _confirmDelete : null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogActivitySheet,
        backgroundColor: const Color(0xFF2AB3EF),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Log Activity',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero header ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E2E), Color(0xFF2A2A4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white10,
                    child: Text(
                      _lead.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_lead.companyName != null)
                          Text(
                            _lead.companyName!,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 13),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _stageColor(_lead.stage)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _stageColor(_lead.stage)),
                              ),
                              child: Text(
                                _lead.stage,
                                style: TextStyle(
                                  color: _stageColor(_lead.stage),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (_lead.amount != null) ...[
                              const SizedBox(width: 10),
                              Text(
                                '₹${_lead.amount}',
                                style: const TextStyle(
                                  color: Color(0xFF67D39F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _contactCircle(Symbols.call, Colors.green),
                      const SizedBox(height: 8),
                      _contactCircle(Symbols.mail, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Stage progress ────────────────────────────────────────────
            if (_lead.stage != 'Lost') ...[
              _sectionTitle('🚀 Pipeline Stage'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _StagePipeline(
                  currentStage: _lead.stage,
                  onStageSelected: _moveStage,
                  stageColor: _stageColor,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Mark as Lost button ───────────────────────────────────────
            if (_lead.stage != 'Won' && _lead.stage != 'Lost')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _moveStage('Lost'),
                  icon: const Icon(Icons.close,
                      color: Colors.redAccent, size: 16),
                  label: const Text('Mark as Lost',
                      style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ── Company Details ───────────────────────────────────────────
            _sectionTitle('🏢 Company Details'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _infoCard(Symbols.business,
                      _lead.companyName ?? '—', 'Company Name'),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.person,
                      _lead.contactPerson ?? '—', 'Contact Person'),
                  const SizedBox(height: 10),
                  _infoCard(
                      Symbols.location_city, _lead.city ?? '—', 'City'),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.call, _lead.phone, 'Phone'),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.mail, _lead.email ?? '—', 'Email'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Service Details ───────────────────────────────────────────
            _sectionTitle('📦 Service Details'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _infoCard(Symbols.home_repair_service,
                      _lead.service ?? '—', 'Service Interested In'),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.currency_rupee,
                      _lead.amount ?? '—', 'Estimated Value'),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.manage_accounts,
                      _lead.assignTo ?? '—', 'Assigned To'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Lead Source ───────────────────────────────────────────────
            _sectionTitle('📡 Lead Source'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _infoCard(
                  Symbols.travel_explore, _lead.leadSource ?? '—', 'Source'),
            ),

            const SizedBox(height: 20),

            // ── Priority & Notes ──────────────────────────────────────────
            _sectionTitle('⚡ Priority & Notes'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Icon(Symbols.flag,
                            color: _priorityColor(_lead.priority), size: 20),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _lead.priority ?? '—',
                              style: TextStyle(
                                color: _priorityColor(_lead.priority),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'Lead Priority',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A3A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notes',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                          _lead.notes ?? 'No notes available.',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Activity Timeline ─────────────────────────────────────────
            _sectionTitle('📋 Activity History'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: activitiesAsync.when(
                data: (activities) => ActivityTimeline(
                  activities: activities,
                  onDelete: (activity) {
                    if (activity.id != null) {
                      ref
                          .read(logActivityProvider.notifier)
                          .deleteActivity(activity.id!);
                    }
                  },
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                        color: Colors.white54, strokeWidth: 2),
                  ),
                ),
                error: (e, _) => Text(
                  'Error loading activities: $e',
                  style: const TextStyle(color: Colors.redAccent),
                ),
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
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoCard(IconData icon, String value, String label) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stage Pipeline Widget ─────────────────────────────────────────────────────
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
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
                              color: (isPast || isCurrent)
                                  ? color
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stage,
                            style: TextStyle(
                              color: isCurrent ? color : Colors.white38,
                              fontSize: 10,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                  gradient: LinearGradient(
                    colors: currentStage == 'Negotiation'
                        ? [
                            const Color(0xFF67D39F),
                            const Color(0xFF2E7D52)
                          ]
                        : [
                            const Color(0xFF96E1FF),
                            const Color(0xFF2AB3EF),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final next = nextStage(currentStage);
                    if (next != null) onStageSelected(next);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    moveButtonLabel(currentStage),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF67D39F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF67D39F)),
              ),
              child: const Center(
                child: Text(
                  '🏆 Deal Won — Client Created',
                  style: TextStyle(
                    color: Color(0xFF67D39F),
                    fontWeight: FontWeight.bold,
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
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _outcomeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Log Activity',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Activity Type',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ActivityType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white60
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(type.emoji,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            type.label,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Outcome / Summary',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _outcomeController,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration:
                  _inputDecor('e.g. Client is interested, follow up Monday'),
            ),
            const SizedBox(height: 12),
            const Text('Additional Notes (optional)',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              cursorColor: Colors.white,
              decoration: _inputDecor('Any extra details...'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF96E1FF), Color(0xFF2AB3EF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
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
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Save Activity',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white38),
      ),
    );
  }
}
