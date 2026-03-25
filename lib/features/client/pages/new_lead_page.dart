import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:crm/core/widgets/large_text_field.dart';
import 'package:flutter/material.dart';

class NewLeadPage extends StatefulWidget {
  const NewLeadPage({super.key});

  @override
  State<NewLeadPage> createState() => _NewLeadPageState();
}

class _NewLeadPageState extends State<NewLeadPage> {
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
    leadData.add({
      "companyName": _companyNameController.text,
      "contactPerson": _contactPersonController.text,
      "city": _cityController.text,
      "phone": _phoneController.text,
      "email": _emailController.text,
      "estimatedValue": _estimatedValueController.text,
      "notes": _notesController.text,
      "services": _serviceController.value.join(", "),
      "assignTo": _assignToController.value ?? "",
      "source": _selectedSource ?? "",
      "priority": _selectedPriority,
    });
  }

  CustomDropdownDecoration get _dropdownDecoration => CustomDropdownDecoration(
    closedFillColor: const Color(0xFF0D0D0D),
    expandedFillColor: const Color(0xFF1A1A1A),
    hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
    listItemStyle: const TextStyle(color: Colors.white, fontSize: 14),
    closedSuffixIcon: const Icon(
      Icons.keyboard_arrow_down,
      color: Colors.white38,
    ),
    expandedSuffixIcon: const Icon(
      Icons.keyboard_arrow_up,
      color: Colors.white38,
    ),
    closedBorder: Border.all(color: Colors.white12),
    expandedBorder: Border.all(color: const Color(0xFF96E1FF), width: 1.5),
    closedBorderRadius: BorderRadius.circular(10),
    expandedBorderRadius: BorderRadius.circular(10),
    headerStyle: const TextStyle(color: Colors.white, fontSize: 14),
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
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add New Lead",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SizedBox(
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF96E1FF), Color(0xFF2AB3EF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF96E1FF).withValues(alpha: 0.25),
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
                  color: Colors.black,
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
                            ? const Color(0xFF96E1FF).withValues(alpha: 0.12)
                            : const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF96E1FF)
                              : Colors.white12,
                        ),
                      ),
                      child: Text(
                        source,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF96E1FF)
                              : Colors.white54,
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
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: "e.g. Very interested, follow up Monday...",
                        hintStyle: TextStyle(
                          color: Colors.white38,
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

  // ── Section card wrapper ──
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
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
        style: const TextStyle(color: Colors.white38, fontSize: 12),
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
              : const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.white38,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
