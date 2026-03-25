import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class LeadsCard extends StatelessWidget {
  const LeadsCard({
    super.key,
    required this.name,
    this.companyName,
    this.email,
    required this.phone,
    required this.stage,
    required this.lastContacted,
  });
  final String name;
  final String? companyName;
  final String? email;
  final String phone;
  final String stage;
  final String lastContacted;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white30,
          child: Icon(Symbols.person, color: Colors.white24),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                companyName ?? "No Company",
                style: TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Symbols.mail, color: Colors.white30, size: 16),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      email ?? "No Email",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Symbols.call, color: Colors.white30, size: 16),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      phone,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Icon(Symbols.calendar_today, color: Colors.white30, size: 14),
                SizedBox(width: 4),
                Text(
                  lastContacted,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                stage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
