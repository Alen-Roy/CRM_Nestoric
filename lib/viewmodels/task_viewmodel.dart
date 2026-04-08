import 'package:crm/models/task_model.dart';
import 'package:crm/repositories/task_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Repository provider ───────────────────────────────────────────────────────
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

// ── Tasks stream from Firestore ───────────────────────────────────────────────
final tasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getTasks(user.uid);
});

// ── Task action notifier ──────────────────────────────────────────────────────
// Handles add / toggle / delete against Firestore.
class TaskActionNotifier extends Notifier<AsyncValue<void>> {
  late final TaskRepository _repo;

  @override
  AsyncValue<void> build() {
    _repo = ref.watch(taskRepositoryProvider);
    return const AsyncValue.data(null);
  }

  Future<void> addTask(TaskModel task) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addTask(task);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleTask(TaskModel task) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateTask(task.copyWith(isDone: !task.isDone));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(String taskId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteTask(taskId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final taskActionProvider =
    NotifierProvider<TaskActionNotifier, AsyncValue<void>>(
  TaskActionNotifier.new,
);

// ── Keep old tasksProvider alias so nothing else breaks ───────────────────────
// TaskPage and TaskAddPage will be updated to use the new providers.
