import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/lead_model.dart';

class LeadRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'leads';

  Future<void> addLead(LeadModel lead) async {
    await _firestore.collection(_collection).add(lead.toMap());
  }

  Stream<List<LeadModel>> getLeads(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final leads = snapshot.docs.map((doc) {
            return LeadModel.fromMap(doc.data(), doc.id);
          }).toList();

          leads.sort((a, b) {
            final aTime = a.createdAt ?? DateTime(1970);
            final bTime = b.createdAt ?? DateTime(1970);
            return bTime.compareTo(aTime);
          });

          return leads;
        });
  }

  Future<void> updateLead(LeadModel lead) async {
    if (lead.id == null) throw Exception('Cannot update a lead without an ID');
    await _firestore.collection(_collection).doc(lead.id).update(lead.toMap());
  }

  Future<void> deleteLead(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  /// Writes only the lastContacted fields — no full LeadModel needed.
  /// Used when logging an activity from ClientDetailPage where we have
  /// a leadId but not the full LeadModel in scope.
  Future<void> stampLastContacted(String leadId) async {
    final now = DateTime.now();
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final display = '${now.day} ${months[now.month]} ${now.year}';
    await _firestore.collection(_collection).doc(leadId).update({
      'lastContacted':   display,
      'lastContactedAt': Timestamp.fromDate(now),
    });
  }
}
