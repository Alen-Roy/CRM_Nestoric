import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/widgets/activity_timeline.dart';
import 'package:crm/core/widgets/image_button.dart';
import 'package:crm/models/activity_model.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/viewmodels/activity_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ClientDetailPage extends ConsumerWidget {
  final ClientModel client;
  const ClientDetailPage({super.key, required this.client});

  Color _statusColor(String status) {
    switch (status) {
      case ClientStatus.vip:       return AppColors.accent3;
      case ClientStatus.active:    return AppColors.success;
      case ClientStatus.inactive:  return AppColors.textLight;
      default:                     return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesProvider(client.leadId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Client Details', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: AppColors.textMid), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogActivitySheet(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Profile header ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.subtleGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    radius: 48,
                    child: Text(
                      client.name[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(client.name, style: const TextStyle(fontSize: 22, color: AppColors.textDark, fontWeight: FontWeight.w800)),
                  if (client.companyName != null) ...[
                    const SizedBox(height: 4),
                    Text(client.companyName!, style: const TextStyle(fontSize: 14, color: AppColors.textMid)),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: _statusColor(client.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(client.status, style: TextStyle(color: _statusColor(client.status), fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ImageButton(onTap: () {}, image: 'https://img.icons8.com/color/96/phone--v1.png'),
                      ImageButton(onTap: () {}, image: 'https://img.icons8.com/color/96/whatsapp--v1.png'),
                      ImageButton(onTap: () {}, image: 'https://img.icons8.com/color/96/gmail-new.png'),
                    ],
                  ),
                ],
              ),
            ),

            // ── Details body ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Client Details', style: TextStyle(color: AppColors.textDark, fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  _detailRow(Icons.mail_outline, 'Email', client.email ?? '—'),
                  _detailRow(Icons.phone_outlined, 'Phone', client.phone),
                  _detailRow(Icons.business, 'Company', client.companyName ?? '—'),
                  _detailRow(Icons.location_city, 'City', client.city ?? '—'),
                  _detailRow(
                    Icons.monetization_on_outlined, 'Monthly Value',
                    client.monthlyValue != null ? '₹${client.monthlyValue!.toStringAsFixed(0)}' : '—',
                    valueColor: AppColors.success,
                  ),
                  _detailRow(Icons.home_repair_service, 'Service', client.service ?? '—'),
                  _detailRow(Icons.calendar_today, 'Joined', DateFormat('d MMM yyyy').format(client.joinedDate)),
                  if (client.contractRenewal != null)
                    _detailRow(Icons.event_repeat, 'Contract Renewal', DateFormat('d MMM yyyy').format(client.contractRenewal!), valueColor: AppColors.warning),

                  const SizedBox(height: 24),

                  const Text('📋 Activity History', style: TextStyle(color: AppColors.textDark, fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  activitiesAsync.when(
                    data: (activities) => ActivityTimeline(
                      activities: activities,
                      onDelete: (activity) {
                        if (activity.id != null) ref.read(logActivityProvider.notifier).deleteActivity(activity.id!);
                      },
                    ),
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))),
                    error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.danger)),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(color: valueColor ?? AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogActivitySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ClientLogActivitySheet(leadId: client.leadId, ref: ref),
    );
  }
}

// ── Log Activity Sheet ────────────────────────────────────────────────────────
class _ClientLogActivitySheet extends StatefulWidget {
  final String leadId;
  final WidgetRef ref;
  const _ClientLogActivitySheet({required this.leadId, required this.ref});

  @override
  State<_ClientLogActivitySheet> createState() => _ClientLogActivitySheetState();
}

class _ClientLogActivitySheetState extends State<_ClientLogActivitySheet> {
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
            _lightField(_outcomeController, 'e.g. Client needs follow-up next week'),
            const SizedBox(height: 12),
            const Text('Additional Notes (optional)', style: TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _lightField(_notesController, 'Any extra details...', maxLines: 3),
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
                      leadId: widget.leadId,
                      type: _selectedType,
                      outcome: _outcomeController.text.trim().isEmpty ? null : _outcomeController.text.trim(),
                      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Save Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lightField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
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
