import 'package:crm/core/constants/app_colors.dart';
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
  final List<String> _stages = const ['All', 'New', 'Proposal', 'Negotiation', 'Won'];
  int _selectedStage = 0;
  String _searchQuery = '';

  List<LeadModel> _filteredLeads(List<LeadModel> leads) {
    List<LeadModel> result = _selectedStage == 0 ? leads : leads.where((l) => l.stage == _stages[_selectedStage]).toList();
    if (_searchQuery.isNotEmpty) {
      result = result.where((l) => l.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Leads', style: TextStyle(color: AppColors.textDark, fontSize: 26, fontWeight: FontWeight.w800)),
              CustomeSearch(hint: 'Search leads...', onChanged: (v) => setState(() => _searchQuery = v)),
              const SizedBox(height: 14),
              // Filter chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _stages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedStage == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStage = index),
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
                          _stages[index],
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
                child: leadsAsync.when(
                  data: (leads) {
                    final filtered = _filteredLeads(leads);
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text('No leads found.', style: TextStyle(color: AppColors.textLight, fontSize: 15)),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final lead = filtered[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeadDetailPage(lead: lead))),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: LeadsCard(
                              name: lead.name,
                              companyName: lead.companyName ?? '',
                              email: lead.email ?? '',
                              phone: lead.phone,
                              stage: lead.stage,
                              lastContacted: lead.lastContacted ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.danger))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
