import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/client/pages/client_detail_page.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/viewmodels/client_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class ClientPage extends ConsumerStatefulWidget {
  const ClientPage({super.key});
  @override
  ConsumerState<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends ConsumerState<ClientPage> {
  final List<String> _statuses = const ['All', 'Active', 'VIP', 'Inactive', 'Completed'];
  int _selectedStatus = 0;
  String _searchQuery = '';
  bool _showSearch = false;
  final _controller = TextEditingController();

  List<ClientModel> _filtered(List<ClientModel> clients) {
    List<ClientModel> r = _selectedStatus == 0
        ? clients
        : clients.where((c) => c.status == _statuses[_selectedStatus]).toList();
    if (_searchQuery.isNotEmpty) {
      r = r.where((c) =>
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.companyName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
    }
    return r;
  }

  Color _statusColor(String s) {
    switch (s) {
      case ClientStatus.vip:       return AppColors.primaryMid;
      case ClientStatus.active:    return AppColors.primary;
      case ClientStatus.inactive:  return AppColors.textLight;
      case ClientStatus.completed: return AppColors.primaryGlow;
      default:                     return AppColors.textLight;
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────────────────────
                  Row(children: [
                    const Text('Clients', style: TextStyle(color: AppColors.textDark, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() { _showSearch = !_showSearch; if (!_showSearch) { _searchQuery = ''; _controller.clear(); } }),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: _showSearch ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _showSearch ? AppColors.primarySoft : AppColors.border),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withValues(alpha: _showSearch ? 0.25 : 0.07), blurRadius: 12, offset: const Offset(0, 4)),
                            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 5, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Icon(Icons.search_rounded, color: _showSearch ? Colors.white : AppColors.textDark, size: 20),
                      ),
                    ),
                  ]),

                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    firstChild: const SizedBox(height: 14),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 2),
                      child: TextField(
                        controller: _controller,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        autofocus: true,
                        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          hintText: 'Search clients...',
                          hintStyle: const TextStyle(color: AppColors.textLight),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textLight, size: 20),
                          filled: true, fillColor: AppColors.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    crossFadeState: _showSearch ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  ),

                  const SizedBox(height: 6),

                  // ── Filter pills ─────────────────────────────────────────
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _statuses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final isSel = _selectedStatus == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStatus = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(50),
                              border: isSel ? null : Border.all(color: AppColors.border),
                              boxShadow: isSel
                                  ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 10, offset: const Offset(0, 4))]
                                  : [],
                            ),
                            child: Text(_statuses[i], style: TextStyle(color: isSel ? Colors.white : AppColors.textMid, fontSize: 13, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Client list ───────────────────────────────────────────────
            Expanded(
              child: clientsAsync.when(
                data: (clients) {
                  final shown = _filtered(clients);
                  if (shown.isEmpty) {
                    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 70, height: 70, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Symbols.person, color: AppColors.primary, size: 34)),
                      const SizedBox(height: 14),
                      const Text('No clients found', style: TextStyle(color: AppColors.textMid, fontSize: 16, fontWeight: FontWeight.w600)),
                    ]));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                    itemCount: shown.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _ClientCard(client: shown[i], statusColor: _statusColor(shown[i].status)),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.danger))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final ClientModel client;
  final Color statusColor;
  const _ClientCard({required this.client, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientDetailPage(client: client))),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 5)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          // Avatar with status ring
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight,
              child: Text(client.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(client.name, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w700)),
            if (client.companyName != null)
              Text(client.companyName!, style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
            const SizedBox(height: 4),
            if (client.monthlyValue != null)
              Row(children: [
                const Icon(Symbols.currency_rupee, color: AppColors.primary, size: 13),
                Text('${client.monthlyValue!.toStringAsFixed(0)}/mo', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
          ])),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
            child: Text(client.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}
