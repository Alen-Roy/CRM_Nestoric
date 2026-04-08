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
      case ClientStatus.vip:
        return const Color(0xFFFFC97A);
      case ClientStatus.active:
        return const Color(0xFF67D39F);
      case ClientStatus.inactive:
        return Colors.white38;
      default:
        return const Color(0xFF96E1FF);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesProvider(client.leadId));

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
          'Client Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogActivitySheet(context, ref),
        backgroundColor: const Color(0xFF2AB3EF),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Log Activity',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFF121212)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white12,
                      radius: 50,
                      child: Text(
                        client.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      client.name,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (client.companyName != null)
                      Text(
                        client.companyName!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            _statusColor(client.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _statusColor(client.status)),
                      ),
                      child: Text(
                        client.status,
                        style: TextStyle(
                          color: _statusColor(client.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ImageButton(
                          onTap: () {},
                          image:
                              'https://img.icons8.com/color/96/phone--v1.png',
                        ),
                        ImageButton(
                          onTap: () {},
                          image:
                              'https://img.icons8.com/color/96/whatsapp--v1.png',
                        ),
                        ImageButton(
                          onTap: () {},
                          image:
                              'https://img.icons8.com/color/96/gmail-new.png',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Client Details ───────────────────────────────────────
                    const Text(
                      'Client Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _detailRow(Icons.mail_outline, 'Email',
                        client.email ?? '—'),
                    _detailRow(Icons.phone_outlined, 'Phone', client.phone),
                    _detailRow(Icons.business, 'Company',
                        client.companyName ?? '—'),
                    _detailRow(
                        Icons.location_city, 'City', client.city ?? '—'),
                    _detailRow(
                      Icons.monetization_on_outlined,
                      'Monthly Value',
                      client.monthlyValue != null
                          ? '₹${client.monthlyValue!.toStringAsFixed(0)}'
                          : '—',
                      valueColor: const Color(0xFF67D39F),
                    ),
                    _detailRow(
                      Icons.home_repair_service,
                      'Service',
                      client.service ?? '—',
                    ),
                    _detailRow(
                      Icons.calendar_today,
                      'Joined',
                      DateFormat('d MMM yyyy').format(client.joinedDate),
                    ),
                    if (client.contractRenewal != null)
                      _detailRow(
                        Icons.event_repeat,
                        'Contract Renewal',
                        DateFormat('d MMM yyyy').format(client.contractRenewal!),
                        valueColor: const Color(0xFFFFC97A),
                      ),

                    const SizedBox(height: 20),

                    // ── Activity History ──────────────────────────────────────
                    const Text(
                      '📋 Activity History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    activitiesAsync.when(
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
                        'Error: $e',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),

                    const SizedBox(height: 100), // FAB clearance
                  ],
                ),
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
      builder: (ctx) => _LogActivitySheet(
        leadId: client.leadId,
        ref: ref,
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white38, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 14,
                      fontWeight: valueColor != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Log Activity bottom sheet for ClientDetailPage ────────────────────────────
class _LogActivitySheet extends StatefulWidget {
  final String leadId;
  final WidgetRef ref;

  const _LogActivitySheet({required this.leadId, required this.ref});

  @override
  State<_LogActivitySheet> createState() => _LogActivitySheetState();
}

class _LogActivitySheetState extends State<_LogActivitySheet> {
  ActivityType _selectedType = ActivityType.call;
  final outcomeController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void dispose() {
    outcomeController.dispose();
    notesController.dispose();
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
                fontWeight: FontWeight.bold,
              ),
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
              controller: outcomeController,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: _inputDecor(
                  'e.g. Client needs follow-up next week'),
            ),
            const SizedBox(height: 12),
            const Text('Additional Notes (optional)',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: notesController,
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
                          outcome: outcomeController.text.trim().isEmpty
                              ? null
                              : outcomeController.text.trim(),
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
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
