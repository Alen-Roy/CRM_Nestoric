import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class LeadDetailPage extends StatelessWidget {
  final Map<String, String> lead;

  const LeadDetailPage({super.key, required this.lead});

  Color _priorityColor(String? priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.amber;
      case "Low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E2E), Color(0xFF2A2A4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 50,
                    left: 16,
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white24,
                      child: Text(
                        lead["name"]![0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          lead["name"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          lead["companyName"] ?? "",
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lead["amount"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.green,
                              child: const Icon(
                                Symbols.call,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.green,
                              child: const Icon(
                                Symbols.mail,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 7,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        lead["stage"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 🏢 Company Details ──
            _sectionTitle("🏢 Company Details"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _infoCard(
                    Symbols.business,
                    lead["companyName"] ?? "—",
                    "Company Name",
                  ),
                  const SizedBox(height: 10),
                  _infoCard(
                    Symbols.person,
                    lead["contactPerson"] ?? "—",
                    "Contact Person",
                  ),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.location_city, lead["city"] ?? "—", "City"),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.call, lead["phone"] ?? "—", "Phone"),
                  const SizedBox(height: 10),
                  _infoCard(Symbols.mail, lead["email"] ?? "—", "Email"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 📦 Service Details ──
            _sectionTitle("📦 Service Details"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _infoCard(
                    Symbols.home_repair_service,
                    lead["service"] ?? "—",
                    "Service Interested In",
                  ),
                  const SizedBox(height: 10),
                  _infoCard(
                    Symbols.currency_rupee,
                    lead["amount"] ?? "—",
                    "Estimated Value",
                  ),
                  const SizedBox(height: 10),
                  _infoCard(
                    Symbols.manage_accounts,
                    lead["assignTo"] ?? "—",
                    "Assigned To",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 📡 Lead Source ──
            _sectionTitle("📡 Lead Source"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _infoCard(
                Symbols.travel_explore,
                lead["leadSource"] ?? "—",
                "Source",
              ),
            ),

            const SizedBox(height: 20),

            // ── ⚡ Priority ──
            _sectionTitle("⚡ Priority & Notes"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Priority badge card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.flag,
                          color: _priorityColor(lead["priority"]),
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead["priority"] ?? "—",
                              style: TextStyle(
                                color: _priorityColor(lead["priority"]),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "Lead Priority",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Notes card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A3A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Notes",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Symbols.edit_square,
                              color: Colors.white54,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lead["notes"] ?? "No notes available.",
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 📞 Last Contacted ──
            _sectionTitle("📞 Recent Activity"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _infoCard(
                Symbols.calendar_today,
                lead["lastContacted"] ?? "—",
                "Last Contacted",
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Section title ──
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ── Reusable info card ──
  Widget _infoCard(IconData icon, String value, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
