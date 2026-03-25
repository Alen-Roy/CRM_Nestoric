import 'package:crm/core/widgets/image_button.dart';
import 'package:flutter/material.dart';

class ClientDetailPage extends StatefulWidget {
  final Map<String, String> client;

  const ClientDetailPage({super.key, required this.client});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  final List<String> _notes = [];

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

  void _showAddNoteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Add Note",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Type your note here...",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF121212),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white38),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() => _notes.add(text));
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;
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
          "Client Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFF121212)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white12,
                      radius: 50,
                      child: Text(
                        (client["name"] ?? "?")[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      client["name"] ?? "—",
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      client["companyName"] ?? "—",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ImageButton(
                          onTap: () {},
                          image:
                              "https://img.icons8.com/color/96/phone--v1.png",
                        ),
                        ImageButton(
                          onTap: () {},
                          image:
                              "https://img.icons8.com/color/96/whatsapp--v1.png",
                        ),
                        ImageButton(
                          onTap: () {},
                          image:
                              "https://img.icons8.com/color/96/gmail-new.png",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              icon: Icons.handshake,
                              label: "Start Meeting",
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _actionCard(
                              icon: Icons.note_add,
                              label: "Take Note",
                              onTap: _showAddNoteDialog,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
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
                          GestureDetector(
                            onTap: _showAddNoteDialog,
                            child: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white54,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (_notes.isEmpty &&
                          (client["notes"] == null || client["notes"]!.isEmpty))
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121212),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Text(
                            "No notes yet. Tap \"Take Note\" to add one.",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else ...[
                        if (client["notes"] != null &&
                            client["notes"]!.isNotEmpty)
                          _noteBullet(client["notes"]!),
                        ..._notes.asMap().entries.map(
                          (entry) => _noteBullet(
                            entry.value,
                            onDelete: () =>
                                setState(() => _notes.removeAt(entry.key)),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      const Text(
                        "Client Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _detailRow(
                        Icons.mail_outline,
                        "Email",
                        client["email"] ?? "—",
                      ),
                      _detailRow(
                        Icons.phone_outlined,
                        "Phone",
                        client["phone"] ?? "—",
                      ),
                      _detailRow(
                        Icons.business,
                        "Company",
                        client["companyName"] ?? "—",
                      ),
                      _detailRow(
                        Icons.location_city,
                        "City",
                        client["city"] ?? "—",
                      ),
                      _detailRow(
                        Icons.flag_outlined,
                        "Priority",
                        client["priority"] ?? "—",
                        valueColor: _priorityColor(client["priority"]),
                      ),
                      _detailRow(
                        Icons.calendar_today,
                        "Last Contacted",
                        client["lastContacted"] ?? "—",
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteBullet(String note, {VoidCallback? onDelete}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Icon(Icons.circle, color: Colors.white38, size: 8),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                note,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, color: Colors.white24, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white38, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 14,
                      fontWeight: valueColor != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
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
      ),
    );
  }
}
