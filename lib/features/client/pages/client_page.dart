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
  // ── Filter by Status (was incorrectly labeled Priority before) ──────────────
  final List<String> _statuses = const [
    'All',
    'Active',
    'VIP',
    'Inactive',
    'Completed',
  ];

  int _selectedStatus = 0;
  String _searchQuery = '';

  List<ClientModel> _filteredClients(List<ClientModel> clients) {
    List<ClientModel> result = _selectedStatus == 0
        ? clients
        : clients
            .where((c) => c.status == _statuses[_selectedStatus])
            .toList();

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((c) =>
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (c.companyName
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }
    return result;
  }

  Color _statusColor(String status) {
    switch (status) {
      case ClientStatus.vip:
        return const Color(0xFFFFC97A);
      case ClientStatus.active:
        return const Color(0xFF67D39F);
      case ClientStatus.inactive:
        return Colors.white38;
      case ClientStatus.completed:
        return const Color(0xFF96E1FF);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Now consuming the real Firestore stream of ClientModel objects
    final clientsAsync = ref.watch(clientsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Clients',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CustomeSearch(
                hint: 'Search clients...',
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Filter by Status',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _statuses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedStatus == index;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedStatus = index),
                      child: Container(
                        alignment: Alignment.center,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                isSelected ? Colors.white60 : Colors.white30,
                          ),
                        ),
                        child: Text(
                          _statuses[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: clientsAsync.when(
                  data: (clients) {
                    final shown = _filteredClients(clients);

                    if (shown.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline,
                                color: Colors.white24, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              clients.isEmpty
                                  ? 'No clients yet.\nMark a lead as Won to create a client.'
                                  : 'No clients match your filter.',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: shown.length,
                      itemBuilder: (context, index) {
                        final client = shown[index];
                        final statusColor = _statusColor(client.status);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ClientDetailPage(client: client),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141414),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.08),
                                  child: Text(
                                    client.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        client.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (client.companyName != null)
                                        Text(
                                          client.companyName!,
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12),
                                        ),
                                      if (client.monthlyValue != null)
                                        Text(
                                          '₹${client.monthlyValue!.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: Color(0xFF67D39F),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: statusColor),
                                  ),
                                  child: Text(
                                    client.status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white54),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.red),
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
}
