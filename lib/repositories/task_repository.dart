import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'tasks';

  Future<void> addTask(TaskModel task) async =>
      _firestore.collection(_collection).add(task.toMap());

  /// Tasks created by this user (self-created)
  Stream<List<TaskModel>> getTasks(String userId) => _firestore
      .collection(_collection)
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) {
        final tasks = s.docs.map((d) => TaskModel.fromMap(d.data(), d.id)).toList();
        tasks.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        return tasks;
      });

  /// Tasks assigned TO this worker by the admin
  Stream<List<TaskModel>> getAdminAssignedTasks(String workerUid) => _firestore
      .collection(_collection)
      .where('assignedTo', isEqualTo: workerUid)
      .where('isAdminTask', isEqualTo: true)
      .snapshots()
      .map((s) {
        final tasks = s.docs.map((d) => TaskModel.fromMap(d.data(), d.id)).toList();
        tasks.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        return tasks;
      });

  Future<void> updateTask(TaskModel task) async {
    if (task.id == null) throw Exception('Cannot update task without ID');
    await _firestore.collection(_collection).doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) =>
      _firestore.collection(_collection).doc(id).delete();
}
