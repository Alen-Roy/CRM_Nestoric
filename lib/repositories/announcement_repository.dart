import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/announcement_model.dart';

class AnnouncementRepository {
  final _col = FirebaseFirestore.instance.collection('announcements');

  Stream<List<AnnouncementModel>> stream() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs
          .map((d) => AnnouncementModel.fromMap(d.data(), d.id))
          .toList());

  Future<void> add(AnnouncementModel a) => _col.add(a.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<void> togglePin(String id, bool pinned) =>
      _col.doc(id).update({'isPinned': pinned});
}
