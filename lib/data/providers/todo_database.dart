import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';

class TodoDatabase {
  static const String _boxName = 'todos_box';

  Future<void> init() async {
    await Hive.initFlutter();
    // In a real app, after running build_runner, uncomment the following:
    // Hive.registerAdapter(TodoAdapter());
    await Hive.openBox<Todo>(_boxName);
  }

  Box<Todo> get _box => Hive.box<Todo>(_boxName);

  List<Todo> getTodos() {
    return _box.values.toList();
  }

  Future<void> saveTodos(List<Todo> todos) async {
    await _box.clear();
    await _box.addAll(todos);
  }

  Future<void> saveTodo(Todo todo) async {
    if (todo.id != null) {
      await _box.put(todo.id, todo);
    } else if (todo.localId != null) {
      await _box.put(todo.localId, todo);
    }
  }

  Future<void> deleteTodo(dynamic key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
