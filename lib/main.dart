import 'package:flutter/material.dart';
import 'dbHelper.dart';
import 'todo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<Todo>> _todoList;

  @override
  void initState() {
    super.initState();
    _todoList = _getTodos();
  }

  // Fetch all todos
  Future<List<Todo>> _getTodos() async {
    return await DatabaseHelper.instance.getTodos();
  }

  // Add a new todo
  void _addTodo() async {
    if (_controller.text.isEmpty) return;

    Todo newTodo = Todo(
      task: _controller.text,
    );
    await DatabaseHelper.instance.insert(newTodo);
    setState(() {
      _todoList = _getTodos();
    });
    _controller.clear();
  }

  // Toggle todo completion status
  void _toggleTodoCompletion(Todo todo) async {
    todo.isDone = !todo.isDone;
    await DatabaseHelper.instance.update(todo);
    setState(() {
      _todoList = _getTodos();
    });
  }

  // Delete a todo
  void _deleteTodo(int id) async {
    await DatabaseHelper.instance.delete(id);
    setState(() {
      _todoList = _getTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Todolist")),
      body: FutureBuilder<List<Todo>>(
        future: _todoList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No todos available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Todo todo = snapshot.data![index];
                return ListTile(
                  title: Text(
                    todo.task,
                    style: TextStyle(
                      decoration:
                          todo.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(todo.isDone
                        ? Icons.check_box
                        : Icons.check_box_outline_blank),
                    onPressed: () => _toggleTodoCompletion(todo),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTodo(todo.id!),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  // Show dialog to add a new todo
  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Todo'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Todo Task'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _addTodo();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
