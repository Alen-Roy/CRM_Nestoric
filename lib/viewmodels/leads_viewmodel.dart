import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeadsNotifier extends Notifier<List<Map<String, String>>> {
  @override
  List<Map<String, String>> build() => [
    {
      "name": "John Doe",
      "companyName": "Tech Solutions",
      "contactPerson": "John Doe",
      "city": "Mumbai",
      "email": "john.doe@example.com",
      "phone": "+1 234 567 890",
      "stage": "Won",
      "lastContacted": "12 Mar 2025",
      "notes": "First meeting scheduled. Interested in our software solutions.",
      "amount": "\$5,000",
      "service": "SEO — Search Engine Optimization",
      "assignTo": "Priya Sharma",
      "leadSource": "Google Search",
      "priority": "High",
    },
    {
      "name": "Jane Smith",
      "companyName": "Innovate Inc",
      "contactPerson": "Jane Smith",
      "city": "Delhi",
      "email": "jane.smith@example.com",
      "phone": "+1 987 654 321",
      "stage": "Won",
      "lastContacted": "13 Mar 2025",
      "notes": "Follow-up call scheduled for next week.",
      "amount": "\$10,000",
      "service": "Google Ads / PPC",
      "assignTo": "Amit Kumar",
      "leadSource": "Facebook Ad",
      "priority": "Medium",
    },
  ];

  void updateStage(int index, String newStage) {
    state = [...state]..[index] = {...state[index], "stage": newStage};
  }
}

final leadsProvider =
    NotifierProvider<LeadsNotifier, List<Map<String, String>>>(
      LeadsNotifier.new,
    );
final clientsProvider = Provider(
  (ref) => ref.watch(leadsProvider).where((l) => l["stage"] == "Won").toList(),
);
