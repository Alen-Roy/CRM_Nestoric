import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/models/lead_model.dart';

class ClientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'clients';

  /// Called automatically when a lead is moved to stage 'Won'.
  /// Checks if a client doc for this leadId already exists to avoid duplicates.
  Future<void> createFromLead(LeadModel lead) async {
    // Guard: skip if no ID
    if (lead.id == null) return;

    // Check if client already exists for this lead
    final existing = await _firestore
        .collection(_collection)
        .where('leadId', isEqualTo: lead.id)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return; // already created

    final client = ClientModel.fromLead(lead);
    await _firestore.collection(_collection).add(client.toMap());
  }

  /// Real-time stream of all clients for a user.
  Stream<List<ClientModel>> getClients(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ClientModel.fromMap(doc.data(), doc.id))
              .toList()
            ..sort((a, b) => b.joinedDate.compareTo(a.joinedDate)),
        );
  }

  /// Update an existing client's fields.
  Future<void> updateClient(ClientModel client) async {
    if (client.id == null) throw Exception('Cannot update client without ID');
    await _firestore
        .collection(_collection)
        .doc(client.id)
        .update(client.toMap());
  }

  /// Delete a client document.
  Future<void> deleteClient(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
