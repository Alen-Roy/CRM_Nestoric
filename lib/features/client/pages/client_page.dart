import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/widgets/custome_search.dart';
import 'package:crm/features/client/pages/client_detail_page.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/viewmodels/client_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientPage extends ConsumerStatefulWidget {
  const ClientPage({super.key});

  @override
  ConsumerState<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends ConsumerState<ClientPage> {
  final List<String> _statuses = const ['All', 'Active', 'VIP', 'Inactive', 'Completed'];
  int _selectedStatus = 0;
  String _searchQuery = '';

  List<ClientModel> _filteredClients(List<ClientModel> clients) {
    List<ClientModel> result = _selectedStatus == 0
        ? clients
        : clients.where((c) => c.status == _statuses[_selectedStatus]).toList();
    if (_searchQuery.isNotEmpty) {
      result = result.where((c) =>
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.companyName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
    }
    return result;
  }

  Color _statusColor(String status) {
    switch (status) {
      case ClientStatus.vip:      return AppColors.accent3;
      case ClientStatus.active:   return AppColors.success;
      case ClientStatus.inactive: return AppColors.textLight;
      case ClientStatus.completed: return AppColors.secondary;
      default:                    return AppColors.textLight;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case ClientStatus.vip:      return AppColors.accent3.withOpacity(0.12);
      case ClientStatus.active:   return AppColors.success.withOpacity(0.10);
      case ClientStatus.inactive: return AppColors.border;
      case ClientStatus.completed: return AppColors.secondary.withOpacity(0.10);
      default:                    return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Clients', style: TextStyle(color: AppColors.textDark, fontSize: 26, fontWeight: FontWeight.w800)),
              CustomeSearch(hint: 'Search clients...', onChanged: (v) => setState(() => _searchQuery = v)),
              const SizedBox(height: 14),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _statuses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedStatus == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStatus = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
                              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Text(
                          _statuses[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textMid,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: clientsAsync.when(
                  data: (clients) {
                    final shown = _filteredClients(clients);
                    if (shown.isEmpty) {
                      return const Center(child: Text('No clients found.', style: TextStyle(color: AppColors.textLight, fontSize: 15)));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: shown.length,
                      itemBuilder: (context, index) {
                        final client = shown[index];
                        final statusColor = _statusColor(client.status);
                        final statusBg = _statusBg(client.status);
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ClientDetailPage(client: client))),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.primaryLight,
                                  child: Text(
                                    client.name[0].toUpperCase(),
                                    style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(client.name, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w700)),
                                      if (client.companyName != null)
                                        Text(client.companyName!, style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
                                      if (client.monthlyValue != null)
                                        Text(
                                          '₹${client.monthlyValue!.toStringAsFixed(0)}',
                                          style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                                  child: Text(client.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.danger))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
