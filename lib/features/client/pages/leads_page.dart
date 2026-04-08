import 'package:crm/core/widgets/custome_search.dart';
import 'package:crm/core/widgets/leads_card.dart';
import 'package:crm/features/client/pages/lead_detail_page.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeadsPage extends ConsumerStatefulWidget {
  const LeadsPage({super.key});

  @override
  ConsumerState<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends ConsumerState<LeadsPage> {
  final List<String> _stages = const [
    "All",
    "New",
    "Proposal",
    "Negotiation",
    "Won",
  ];

  int _selectedStage = 0;
  String _searchQuery = "";
  List<LeadModel> _filteredLeads(List<LeadModel> leads) {
    List<LeadModel> result = _selectedStage == 0
        ? leads
        : leads.where((lead) => lead.stage == _stages[_selectedStage]).toList();
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (lead) =>
                lead.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                "Leads",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomeSearch(
                hint: "Search leads...",
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Filter by stage",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _stages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedStage == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStage = index),
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
                          _stages[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: leadsAsync.when(
                  data: (leads) {
                    final filtered = _filteredLeads(leads);

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          "No leads found.",
                          style: TextStyle(color: Colors.white30, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final lead = filtered[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LeadDetailPage(lead: lead),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141414),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: LeadsCard(
                              // IMPORTANT: Use dot-notation for models
                              name: lead.name,
                              companyName: lead.companyName ?? "",
                              email: lead.email ?? "",
                              phone: lead.phone,
                              stage: lead.stage,
                              lastContacted: lead.lastContacted ?? "",
                            ),
                          ),
                        );
                      },
                    );
                  },
                  // Show a spinner while Firestore makes the network request
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  // Show text if an error crashes the stream
                  error: (error, stack) => Center(
                    child: Text(
                      "Error: $error",
                      style: TextStyle(color: Colors.red),
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
