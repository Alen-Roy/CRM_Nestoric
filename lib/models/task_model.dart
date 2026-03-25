class TaskModel {
  final String title;
  bool isDone;
  DateTime createdAt;

  TaskModel({
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });
}
