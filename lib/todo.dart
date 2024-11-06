class Todo {
  int? id;
  String task;
  bool isDone;

  Todo({
    this.id,
    required this.task,
    this.isDone = false,
  });

  // Convert a Todo into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'isDone': isDone ? 1 : 0, // Convert boolean to integer
    };
  }

  // Extract a Todo from a Map object
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      task: map['task'],
      isDone: map['isDone'] == 1, // Convert integer back to boolean
    );
  }
}
