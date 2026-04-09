import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'tasks';

  /// Add a new task to Firestore.
  Future<void> addTask(TaskModel task) async {
    await _firestore.collection(_collection).add(task.toMap());
  }

  /// Real-time stream of tasks for a given user, ordered by scheduledAt.
  /// Sorting is done in Dart to avoid requiring a composite Firestore index.
  Stream<List<TaskModel>> getTasks(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList();
          tasks.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
          return tasks;
        });
  }

  /// Toggle done / undo on a task.
  Future<void> updateTask(TaskModel task) async {
    if (task.id == null) throw Exception('Cannot update task without ID');
    await _firestore
        .collection(_collection)
        .doc(task.id)
        .update(task.toMap());
  }

  /// Delete a task.
  Future<void> deleteTask(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
