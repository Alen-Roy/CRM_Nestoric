class TaskModel {
  final String title;
  final DateTime scheduledAt;
  bool isDone;

  TaskModel({
    required this.title,
    required this.scheduledAt,
    this.isDone = false,
  });
}
