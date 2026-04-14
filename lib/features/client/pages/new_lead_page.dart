import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class NewLeadPage extends ConsumerStatefulWidget {
  const NewLeadPage({super.key});
  @override
  ConsumerState<NewLeadPage> createState() => _NewLeadPageState();
}

class _NewLeadPageState extends ConsumerState<NewLeadPage> {
  final _companyNameCtrl   = TextEditingController();
  final _contactPersonCtrl = TextEditingController();
  final _cityCtrl          = TextEditingController();
  final _phoneCtrl         = TextEditingController();
  final _emailCtrl         = TextEditingController();
  final _valueCtrl         = TextEditingController();
  final _notesCtrl         = TextEditingController();

  final _serviceCtrl = MultiSelectController<String>([]);
  final _assignCtrl  = SingleSelectController<String?>(null);

  String? _selectedSource;
  String  _selectedPriority = 'Medium';

  String? _phoneError;
  String? _nameError;

  final List<String> _services = [
    'Social Media Management', 'Google Ads / PPC', 'SEO', 'Instagram Ads',
    'Facebook Ads', 'Full Digital Marketing Package', 'Content Creation',
    'Website Design', 'Email Marketing', 'Other',
  ];
  final List<String> _assignees = ['Priya Sharma', 'Amit Kumar', 'Sneha Patel', 'Myself'];
  final List<String> _sources   = [
    'Inbound Call', 'Website Form', 'WhatsApp', 'Referral',
    'Facebook Ad', 'Google Search', 'Walk-in', 'Exhibition',
  ];

  @override
  void dispose() {
    _companyNameCtrl.dispose(); _contactPersonCtrl.dispose(); _cityCtrl.dispose();
    _phoneCtrl.dispose(); _emailCtrl.dispose(); _valueCtrl.dispose();
    _notesCtrl.dispose(); _serviceCtrl.dispose(); _assignCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _phoneError = null;
      _nameError  = null;
      if (_phoneCtrl.text.trim().isEmpty) {
        _phoneError = 'Phone number is required';
        valid = false;
      } else if (_phoneCtrl.text.trim().length < 7) {
        _phoneError = 'Enter a valid phone number';
        valid = false;
      }
      if (_companyNameCtrl.text.trim().isEmpty && _contactPersonCtrl.text.trim().isEmpty) {
        _nameError = 'Enter company name or contact person';
        valid = false;
      }
    });
    return valid;
  }

  Future<void> _save() async {
    if (!_validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fix the errors above before saving'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final lead = LeadModel(
      name:          _contactPersonCtrl.text.trim().isNotEmpty
                       ? _contactPersonCtrl.text.trim()
                       : _companyNameCtrl.text.trim(),
      companyName:   _companyNameCtrl.text.trim().isEmpty ? null : _companyNameCtrl.text.trim(),
      contactPerson: _contactPersonCtrl.text.trim().isEmpty ? null : _contactPersonCtrl.text.trim(),
      city:          _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      phone:         _phoneCtrl.text.trim(),
      email:         _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      amount:        _valueCtrl.text.trim().isEmpty ? null : _valueCtrl.text.trim(),
      notes:         _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      service:       _serviceCtrl.value.isEmpty ? null : _serviceCtrl.value.join(', '),
      assignTo:      _assignCtrl.value,
      leadSource:    _selectedSource,
      priority:      _selectedPriority.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
      stage:         'New',
      userId:        user.uid,
    );
    await ref.read(leadRepositoryProvider).addLead(lead);
    if (mounted) Navigator.pop(context);
  }

  CustomDropdownDecoration get _dropDeco => CustomDropdownDecoration(
    closedFillColor:      AppColors.surface,
    expandedFillColor:    AppColors.surfaceTint,
    hintStyle:            const TextStyle(color: AppColors.textLight, fontSize: 14),
    listItemStyle:        const TextStyle(color: AppColors.textDark, fontSize: 14),
    closedSuffixIcon:     const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
    expandedSuffixIcon:   const Icon(Icons.keyboard_arrow_up,   color: AppColors.primary),
    closedBorder:         Border.all(color: AppColors.border),
    expandedBorder:       Border.all(color: AppColors.primary, width: 1.5),
    closedBorderRadius:   BorderRadius.circular(14),
    expandedBorderRadius: BorderRadius.circular(14),
    headerStyle:          const TextStyle(color: AppColors.textDark, fontSize: 14),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4)),
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 16),
                  ),
                ),
                const SizedBox(width: 16),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Add New Lead',
                      style: TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.w800)),
                  Text('Fill in the details below',
                      style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Scrollable form ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Section 1: Company Details ───────────────────────────
                    _sectionCard(
                      icon: Symbols.business,
                      title: 'Company Details',
                      color: AppColors.primary,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        _field('Company / Business Name', _companyNameCtrl,
                            "e.g. Ravi's Restaurant", Icons.business_outlined),
                        if (_nameError != null) _errorText(_nameError!),
                        const SizedBox(height: 14),

                        _field('Contact Person', _contactPersonCtrl,
                            'Full name', Icons.person_outline),
                        const SizedBox(height: 14),

                        _field('City', _cityCtrl,
                            'e.g. Mumbai', Icons.location_city_outlined),
                        const SizedBox(height: 14),

                        _field('Phone *', _phoneCtrl, '+91 XXXXX',
                            Icons.phone_outlined,
                            type: TextInputType.phone, hasError: _phoneError != null),
                        if (_phoneError != null) _errorText(_phoneError!),
                        const SizedBox(height: 14),

                        _field('Email', _emailCtrl, 'email@example.com',
                            Icons.email_outlined, type: TextInputType.emailAddress),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // ── Section 2: Service & Value ───────────────────────────
                    _sectionCard(
                      icon: Symbols.home_repair_service,
                      title: 'Service & Value',
                      color: AppColors.primaryGlow,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        _label('Service Interested In'),
                        CustomDropdown<String>.multiSelect(
                          items: _services,
                          multiSelectController: _serviceCtrl,
                          hintText: 'Select services',
                          decoration: _dropDeco,
                          onListChanged: (_) {},
                        ),
                        const SizedBox(height: 14),

                        _field('Estimated Value', _valueCtrl, '₹ amount',
                            Icons.currency_rupee_outlined,
                            type: TextInputType.number),
                        const SizedBox(height: 14),

                        _label('Assign To'),
                        CustomDropdown<String>(
                          items: _assignees,
                          controller: _assignCtrl,
                          hintText: 'Select team member',
                          decoration: _dropDeco,
                          onChanged: (_) {},
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // ── Section 3: Source & Priority ─────────────────────────
                    _sectionCard(
                      icon: Symbols.travel_explore,
                      title: 'Source & Priority',
                      color: AppColors.primaryMid,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        _label('Lead Source'),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _sources.map((s) {
                            final isSel = _selectedSource == s;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSource = s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.primary : AppColors.surface,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
                                  boxShadow: isSel
                                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
                                      : [],
                                ),
                                child: Text(s,
                                    style: TextStyle(
                                        color: isSel ? Colors.white : AppColors.textMid,
                                        fontSize: 12,
                                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        _label('Priority'),
                        Row(children: [
                          _priorityChip('High',   AppColors.danger),
                          const SizedBox(width: 10),
                          _priorityChip('Medium', AppColors.warning),
                          const SizedBox(width: 10),
                          _priorityChip('Low',    AppColors.primary),
                        ]),
                        const SizedBox(height: 16),

                        _label('Notes / What they said'),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _notesCtrl,
                            maxLines: 4,
                            style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                            cursorColor: AppColors.primary,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Very interested, wants follow-up Monday...',
                              hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
                              contentPadding: EdgeInsets.all(14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Save button ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.32), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Lead',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _errorText(String msg) => Padding(
    padding: const EdgeInsets.only(top: 6, left: 4),
    child: Row(children: [
      const Icon(Icons.error_outline, color: AppColors.danger, size: 13),
      const SizedBox(width: 4),
      Text(msg, style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 5)),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 16),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 18),
        child,
      ]),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
  );

  Widget _field(
    String label,
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? type,
    bool hasError = false,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      TextField(
        controller: ctrl,
        keyboardType: type,
        onChanged: (_) {
          if (hasError) setState(() { _phoneError = null; _nameError = null; });
        },
        style: const TextStyle(color: AppColors.textDark, fontSize: 15),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
          prefixIcon: Icon(icon,
              color: hasError ? AppColors.danger : AppColors.textLight, size: 18),
          filled: true, fillColor: AppColors.background,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: hasError ? AppColors.danger : AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: hasError ? AppColors.danger : AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: hasError ? AppColors.danger : AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    ]);
  }

  Widget _priorityChip(String label, Color color) {
    final isSel = _selectedPriority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? color.withOpacity(0.10) : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSel ? color : AppColors.border, width: isSel ? 1.5 : 1),
          ),
          child: Center(child: Text(label,
              style: TextStyle(
                  color: isSel ? color : AppColors.textMid,
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500))),
        ),
      ),
    );
  }
}
