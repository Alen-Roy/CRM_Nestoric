import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/viewmodels/lead_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class EditLeadPage extends ConsumerStatefulWidget {
  final LeadModel lead;
  const EditLeadPage({super.key, required this.lead});

  @override
  ConsumerState<EditLeadPage> createState() => _EditLeadPageState();
}

class _EditLeadPageState extends ConsumerState<EditLeadPage> {
  late final TextEditingController _companyCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _notesCtrl;

  late final SingleSelectController<String?> _assignCtrl;
  String? _selectedSource;
  late String _selectedPriority;
  bool _saving = false;
  String? _phoneError;

  final List<String> _assignees = ['Priya Sharma', 'Amit Kumar', 'Sneha Patel', 'Myself'];
  final List<String> _sources   = [
    '📞 Inbound Call', '🌐 Website Form', '💬 WhatsApp', '👥 Referral',
    '📘 Facebook Ad', '🔍 Google Search', '🤝 Walk-in', '📊 Exhibition',
  ];

  @override
  void initState() {
    super.initState();
    final l = widget.lead;
    _companyCtrl  = TextEditingController(text: l.companyName ?? '');
    _contactCtrl  = TextEditingController(text: l.contactPerson ?? '');
    _cityCtrl     = TextEditingController(text: l.city ?? '');
    _phoneCtrl    = TextEditingController(text: l.phone);
    _emailCtrl    = TextEditingController(text: l.email ?? '');
    _valueCtrl    = TextEditingController(text: l.amount ?? '');
    _notesCtrl    = TextEditingController(text: l.notes ?? '');
    _assignCtrl   = SingleSelectController<String?>(
        _assignees.contains(l.assignTo) ? l.assignTo : null);
    _selectedSource   = l.leadSource;
    _selectedPriority = _normalisePriority(l.priority);
  }

  String _normalisePriority(String? raw) {
    if (raw == null) return '🟡 Medium';
    if (raw.contains('High'))   return '🔴 High';
    if (raw.contains('Low'))    return '🟢 Low';
    return '🟡 Medium';
  }

  @override
  void dispose() {
    _companyCtrl.dispose(); _contactCtrl.dispose(); _cityCtrl.dispose();
    _phoneCtrl.dispose();   _emailCtrl.dispose();   _valueCtrl.dispose();
    _notesCtrl.dispose();   _assignCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() => _phoneError = null);
    if (_phoneCtrl.text.trim().isEmpty) {
      setState(() => _phoneError = 'Phone number is required');
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _saving = true);
    final updated = widget.lead.copyWith(
      companyName:   _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      contactPerson: _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
      name:          _contactCtrl.text.trim().isNotEmpty
                       ? _contactCtrl.text.trim()
                       : (_companyCtrl.text.trim().isNotEmpty ? _companyCtrl.text.trim() : widget.lead.name),
      city:          _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      phone:         _phoneCtrl.text.trim(),
      email:         _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      amount:        _valueCtrl.text.trim().isEmpty ? null : _valueCtrl.text.trim(),
      notes:         _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      assignTo:      _assignCtrl.value,
      leadSource:    _selectedSource,
      priority:      _selectedPriority.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
    );
    await ref.read(leadDetailProvider.notifier).updateLead(updated);
    if (mounted) {
      Navigator.pop(context, updated);   // return updated lead to caller
    }
  }

  CustomDropdownDecoration get _dropDeco => CustomDropdownDecoration(
    closedFillColor:     AppColors.surface,
    expandedFillColor:   AppColors.surfaceTint,
    hintStyle:           const TextStyle(color: AppColors.textLight, fontSize: 14),
    listItemStyle:       const TextStyle(color: AppColors.textDark, fontSize: 14),
    closedSuffixIcon:    const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
    expandedSuffixIcon:  const Icon(Icons.keyboard_arrow_up,   color: AppColors.primary),
    closedBorder:        Border.all(color: AppColors.border),
    expandedBorder:      Border.all(color: AppColors.primary, width: 1.5),
    closedBorderRadius:  BorderRadius.circular(14),
    expandedBorderRadius: BorderRadius.circular(14),
    headerStyle:         const TextStyle(color: AppColors.textDark, fontSize: 14),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.textDark, size: 16),
                  ),
                ),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Edit Lead',
                      style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  Text(widget.lead.name,
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Form ─────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Details
                    _sectionCard(
                      icon: Symbols.business, title: 'Company Details',
                      color: AppColors.primary,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        _field('Company / Business Name', _companyCtrl,
                            'e.g. Ravi\'s Restaurant', Icons.business_outlined),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _field('Contact Person', _contactCtrl,
                              'Full name', Icons.person_outline)),
                          const SizedBox(width: 12),
                          Expanded(child: _field('City', _cityCtrl,
                              'e.g. Mumbai', Icons.location_city_outlined)),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            _field('Phone *', _phoneCtrl, '+91 XXXXX',
                                Icons.phone_outlined,
                                type: TextInputType.phone,
                                hasError: _phoneError != null),
                            if (_phoneError != null) _errorText(_phoneError!),
                          ])),
                          const SizedBox(width: 12),
                          Expanded(child: _field('Email', _emailCtrl,
                              'email@example.com', Icons.email_outlined,
                              type: TextInputType.emailAddress)),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Service & Value
                    _sectionCard(
                      icon: Symbols.home_repair_service,
                      title: 'Service & Value',
                      color: AppColors.primaryGlow,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          Expanded(child: _field('Estimated Value', _valueCtrl,
                              '₹ amount', Icons.currency_rupee_outlined,
                              type: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            _label('Assign To'),
                            CustomDropdown<String>(
                              items: _assignees,
                              controller: _assignCtrl,
                              hintText: 'Select',
                              decoration: _dropDeco,
                              onChanged: (_) {},
                            ),
                          ])),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Source & Priority
                    _sectionCard(
                      icon: Symbols.travel_explore,
                      title: 'Source & Priority',
                      color: AppColors.primaryMid,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        _label('Lead Source'),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _sources.map((s) {
                            final isSel = _selectedSource == s;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSource = s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: isSel
                                          ? AppColors.primary
                                          : AppColors.border),
                                ),
                                child: Text(s,
                                    style: TextStyle(
                                        color: isSel
                                            ? Colors.white
                                            : AppColors.textMid,
                                        fontSize: 12,
                                        fontWeight: isSel
                                            ? FontWeight.w700
                                            : FontWeight.w500)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        _label('Priority'),
                        Row(children: [
                          _priorityChip('🔴 High',   AppColors.danger),
                          const SizedBox(width: 8),
                          _priorityChip('🟡 Medium', AppColors.warning),
                          const SizedBox(width: 8),
                          _priorityChip('🟢 Low',    AppColors.primary),
                        ]),
                        const SizedBox(height: 14),
                        _label('Notes'),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _notesCtrl,
                            maxLines: 4,
                            style: const TextStyle(
                                color: AppColors.textDark, fontSize: 14),
                            cursorColor: AppColors.primary,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Very interested, follow-up Monday...',
                              hintStyle: TextStyle(
                                  color: AppColors.textLight, fontSize: 13),
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

            // ── Save button ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.32),
                        blurRadius: 20,
                        offset: const Offset(0, 8))],
                  ),
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Save Changes',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorText(String msg) => Padding(
    padding: const EdgeInsets.only(top: 4, left: 4),
    child: Row(children: [
      const Icon(Icons.error_outline, color: AppColors.danger, size: 13),
      const SizedBox(width: 4),
      Text(msg, style: const TextStyle(
          color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600)),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 16),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            color: AppColors.textMid,
            fontSize: 12,
            fontWeight: FontWeight.w600)),
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
          if (hasError) setState(() => _phoneError = null);
        },
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
          prefixIcon: Icon(icon,
              color: hasError ? AppColors.danger : AppColors.textLight,
              size: 18),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: hasError ? AppColors.danger : AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: hasError ? AppColors.danger : AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: hasError ? AppColors.danger : AppColors.primary,
                  width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? color.withOpacity(0.12) : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSel ? color : AppColors.border,
                width: isSel ? 1.5 : 1),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isSel ? color : AppColors.textMid,
                    fontSize: 12,
                    fontWeight:
                        isSel ? FontWeight.w700 : FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}
