import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/widgets/large_text_field.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewLeadPage extends ConsumerStatefulWidget {
  const NewLeadPage({super.key});

  @override
  ConsumerState<NewLeadPage> createState() => _NewLeadPageState();
}

class _NewLeadPageState extends ConsumerState<NewLeadPage> {
  final List leadData = [];
  List<Map<String, String>> get leads => leadData.cast<Map<String, String>>();
  final _companyNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _notesController = TextEditingController();

  final _serviceController = MultiSelectController<String>([]);
  final _assignToController = SingleSelectController<String?>(null);

  String? _selectedSource;
  String _selectedPriority = "🟡 Medium";

  final List<String> _services = [
    "Social Media Management",
    "Google Ads / PPC",
    "SEO — Search Engine Optimization",
    "Instagram Ads",
    "Facebook Ads",
    "Full Digital Marketing Package",
    "Content Creation",
    "Website Design",
    "Email Marketing",
    "Other",
  ];

  final List<String> _assignees = [
    "Priya Sharma",
    "Amit Kumar",
    "Sneha Patel",
    "Myself",
  ];

  final List<String> _sources = [
    "📞 Inbound Call",
    "🌐 Website Form",
    "💬 WhatsApp",
    "👥 Referral",
    "📘 Facebook Ad",
    "🔍 Google Search",
    "🤝 Walk-in",
    "📊 Exhibition",
  ];
  Future<void> _handleSave() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final newLead = LeadModel(
      name: _contactPersonController.text.trim().isEmpty
          ? "Un-named Lead"
          : _contactPersonController.text,
      companyName: _companyNameController.text,
      contactPerson: _contactPersonController.text,
      city: _cityController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      amount: _estimatedValueController.text,
      notes: _notesController.text,
      service: _serviceController.value.join(", "),
      assignTo: _assignToController.value ?? "",
      leadSource: _selectedSource ?? "",
      priority: _selectedPriority.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
      stage: "New",
      userId: user.uid,
    );
    await ref.read(leadRepositoryProvider).addLead(newLead);
  }

  CustomDropdownDecoration get _dropdownDecoration => CustomDropdownDecoration(
    closedFillColor: AppColors.surface,
    expandedFillColor: AppColors.surfaceTint,
    hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
    listItemStyle: const TextStyle(color: AppColors.textDark, fontSize: 14),
    closedSuffixIcon: const Icon(
      Icons.keyboard_arrow_down,
      color: AppColors.textLight,
    ),
    expandedSuffixIcon: const Icon(
      Icons.keyboard_arrow_up,
      color: AppColors.textLight,
    ),
    closedBorder: Border.all(color: AppColors.border),
    expandedBorder: Border.all(color: AppColors.primary, width: 1.5),
    closedBorderRadius: BorderRadius.circular(10),
    expandedBorderRadius: BorderRadius.circular(10),
    headerStyle: const TextStyle(color: AppColors.textDark, fontSize: 14),
  );

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _estimatedValueController.dispose();
    _notesController.dispose();
    _serviceController.dispose();
    _assignToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add New Lead",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SizedBox(
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryGlow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                await _handleSave();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Save Lead",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              title: "🏢 Company Details",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel("Company / Business Name"),
                  largeTextField(
                    hintText: "e.g. Ravi's Restaurant",
                    textController: _companyNameController,
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("Contact Person"),
                            largeTextField(
                              hintText: "Full name",
                              textController: _contactPersonController,
                              icon: Icons.person_outline,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("City"),
                            largeTextField(
                              hintText: "e.g. Mumbai",
                              textController: _cityController,
                              icon: Icons.location_city_outlined,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("Phone"),
                            largeTextField(
                              hintText: "+91 XXXXX XXXXX",
                              textController: _phoneController,
                              icon: Icons.phone_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("Email"),
                            largeTextField(
                              hintText: "email@example.com",
                              textController: _emailController,
                              icon: Icons.email_outlined,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: "📦 Service They Want",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel("Service Interested In (select multiple)"),

                  CustomDropdown<String>.multiSelect(
                    items: _services,
                    multiSelectController: _serviceController,
                    hintText: "Select services",
                    decoration: _dropdownDecoration,
                    onListChanged: (val) {},
                  ),

                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("Estimated Value"),
                            largeTextField(
                              hintText: "amount",
                              textController: _estimatedValueController,
                              icon: Icons.currency_rupee_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("Assign To"),
                            CustomDropdown<String>(
                              items: _assignees,
                              controller: _assignToController,
                              hintText: "Select",
                              decoration: _dropdownDecoration,
                              onChanged: (val) {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _sectionCard(
              title: "📡 Lead Source",
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sources.map((source) {
                  final isSelected = _selectedSource == source;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSource = source),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        source,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMid,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: "⚡ Priority & Notes",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel("Lead Priority"),
                  Row(
                    children: [
                      _priorityChip("🔴 High", Colors.red),
                      const SizedBox(width: 8),
                      _priorityChip("🟡 Medium", Colors.amber),
                      const SizedBox(width: 8),
                      _priorityChip("🟢 Low", Colors.green),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _fieldLabel("Notes / What they said"),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      style: const TextStyle(color: AppColors.textDark),
                      cursorColor: AppColors.primary,
                      decoration: const InputDecoration(
                        hintText: "e.g. Very interested, follow up Monday...",
                        hintStyle: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textLight, fontSize: 12),
      ),
    );
  }

  Widget _priorityChip(String label, Color color) {
    final isSelected = _selectedPriority == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textLight,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
