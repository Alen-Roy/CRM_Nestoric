import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/activity_model.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'activities';

  /// Log a new activity against a lead/client.
  Future<void> addActivity(ActivityModel activity) async {
    await _firestore.collection(_collection).add(activity.toMap());
  }

  /// Real-time stream of activities for a given lead, newest first.
  Stream<List<ActivityModel>> getActivities(String leadId) {
    return _firestore
        .collection(_collection)
        .where('leadId', isEqualTo: leadId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ActivityModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Delete an activity by ID.
  Future<void> deleteActivity(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
