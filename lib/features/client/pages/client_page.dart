import 'package:crm/core/widgets/client_card.dart';
import 'package:crm/core/widgets/custome_search.dart';
import 'package:crm/features/client/pages/client_detail_page.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientPage extends ConsumerStatefulWidget {
  const ClientPage({super.key});

  @override
  ConsumerState<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends ConsumerState<ClientPage> {
  final List<String> _priority = const ["All", "High", "Medium", "Low"];
  String _searchQuery = "";

  int _selectedPriority = 0;
  _filteredClients(List<Map<String, String>> clients) {
    List<Map<String, String>> result = _selectedPriority == 0
        ? clients
        : clients
              .where(
                (clients) =>
                    clients["priority"] == _priority[_selectedPriority],
              )
              .toList();
    if (_searchQuery.isNotEmpty) {
      result = clients
          .where(
            (clients) => clients['name']!.toLowerCase().contains(
              _searchQuery.toString(),
            ),
          )
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref
        .watch(leadsProvider)
        .where((clients) => clients["stage"] == "Won")
        .toList();
    final showClients = _filteredClients(clients);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                "Clients",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomeSearch(
                hint: "Search clients...",
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),

              const SizedBox(height: 10),
              const Text(
                "Filter by Priority",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedPriority == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPriority = index;
                          print(_selectedPriority);
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? Colors.white60 : Colors.white30,
                          ),
                        ),
                        child: Text(
                          _priority[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: _priority.length,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: showClients.length,
                  itemBuilder: (BuildContext context, int index) {
                    final client = showClients[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClientDetailPage(client: client),
                            ),
                          );
                        },
                        child: clientCard(
                          name: client['name'] ?? '',
                          companyName: client['companyName'] ?? '',
                          email: client['email'] ?? '',
                          phone: client['phone'] ?? '',
                          lastContacted: client['lastContacted'] ?? '',
                          priority: client['priority'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
