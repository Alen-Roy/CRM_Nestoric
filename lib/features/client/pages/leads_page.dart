import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/client/pages/lead_detail_page.dart';
import 'package:crm/features/client/pages/new_lead_page.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launch(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final mode = (uri.scheme == 'https' || uri.scheme == 'http')
      ? LaunchMode.externalApplication
      : LaunchMode.platformDefault;
  try {
    final launched = await launchUrl(uri, mode: mode);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No app found to open: ${uri.scheme}'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open: $url'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class LeadsPage extends ConsumerStatefulWidget {
  const LeadsPage({super.key});
  @override
  ConsumerState<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends ConsumerState<LeadsPage> {
  final List<String> _stages = const [
    'All',
    'New',
    'Proposal',
    'Negotiation',
    'Won',
  ];
  int _selectedStage = 0;
  String _searchQuery = '';
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LeadModel> _filteredLeads(List<LeadModel> leads) {
    List<LeadModel> result = _selectedStage == 0
        ? leads
        : leads.where((l) => l.stage == _stages[_selectedStage]).toList();
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (l) =>
                l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (l.companyName?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }
    return result;
  }

  Color _stageColor(String s) {
    switch (s) {
      case 'Won':
        return AppColors.primary;
      case 'Proposal':
        return AppColors.primarySoft;
      case 'Negotiation':
        return AppColors.primary;
      case 'New':
        return AppColors.primaryGlow;
      default:
        return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // ── FAB: Add Lead directly from Leads page ──────────────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewLeadPage()),
          ),
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text(
            'Add Lead',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ────────────────────────────────────────────
                  Row(
                    children: [
                      const Text(
                        'Leads',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      // Search toggle
                      GestureDetector(
                        onTap: () => setState(() {
                          _showSearch = !_showSearch;
                          if (!_showSearch) {
                            _searchQuery = '';
                            _searchController.clear();
                          }
                        }),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _showSearch
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _showSearch
                                  ? AppColors.primarySoft
                                  : AppColors.border,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(
                                  _showSearch ? 0.25 : 0.07,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: _showSearch
                                ? Colors.white
                                : AppColors.textDark,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Animated search bar ───────────────────────────────────
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    firstChild: const SizedBox(height: 14),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 2),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                        ),
                        cursorColor: AppColors.primary,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search leads...',
                          hintStyle: const TextStyle(
                            color: AppColors.textLight,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textLight,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                    crossFadeState: _showSearch
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                  ),

                  const SizedBox(height: 6),

                  // ── Stage filter pills ────────────────────────────────────
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _stages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final isSel = _selectedStage == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStage = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(50),
                              border: isSel
                                  ? null
                                  : Border.all(color: AppColors.border),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.28,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              _stages[i],
                              style: TextStyle(
                                color: isSel ? Colors.white : AppColors.textMid,
                                fontSize: 13,
                                fontWeight: isSel
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Lead list ─────────────────────────────────────────────────
            Expanded(
              child: leadsAsync.when(
                data: (leads) {
                  final filtered = _filteredLeads(leads);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Symbols.leaderboard,
                              color: AppColors.primary,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No leads found',
                            style: TextStyle(
                              color: AppColors.textMid,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try a different filter',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _LeadCard(
                      lead: filtered[i],
                      stageColor: _stageColor(filtered[i].stage),
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  final LeadModel lead;
  final Color stageColor;
  const _LeadCard({required this.lead, required this.stageColor});

  @override
  Widget build(BuildContext context) {
    final cleanPhone = lead.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final hasPhone = cleanPhone.isNotEmpty;
    final hasEmail = lead.email != null && lead.email!.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LeadDetailPage(lead: lead)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Lead info ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        lead.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.name,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lead.companyName ?? lead.phone,
                          style: const TextStyle(
                            color: AppColors.textMid,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Symbols.call,
                              color: AppColors.textLight,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lead.phone,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 11,
                              ),
                            ),
                            if (lead.lastContacted != null &&
                                lead.lastContacted!.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              const Icon(
                                Symbols.calendar_today,
                                color: AppColors.textLight,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                lead.lastContacted!,
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Stage badge + amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: stageColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          lead.stage,
                          style: TextStyle(
                            color: stageColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (lead.amount != null && lead.amount!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '₹${lead.amount}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Quick action buttons ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  _ActionBtn(
                    icon: Symbols.call,
                    label: 'Call',
                    color: AppColors.primary,
                    enabled: hasPhone,
                    onTap: hasPhone
                        ? () => _launch(context, 'tel:$cleanPhone')
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    icon: Icons.message_rounded,
                    label: 'WhatsApp',
                    color: AppColors.primary,
                    enabled: hasPhone,
                    onTap: hasPhone
                        ? () => _launch(context, 'https://wa.me/$cleanPhone')
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    icon: Symbols.mail,
                    label: 'Email',
                    color: AppColors.primary,
                    enabled: hasEmail,
                    onTap: hasEmail
                        ? () => _launch(context, 'mailto:${lead.email}')
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    icon: Icons.sms_rounded,
                    label: 'SMS',
                    color: AppColors.primary,
                    enabled: hasPhone,
                    onTap: hasPhone
                        ? () => _launch(context, 'sms:$cleanPhone')
                        : null,
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

// ── Small action button used inside lead card ─────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback? onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap != null
            ? () {
                onTap!();
              }
            : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.25,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
