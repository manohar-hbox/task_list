import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/todo.dart';
import '../providers/todo_api.dart';
import '../providers/todo_database.dart';

class TodoRepository {
  final TodoApi _api;
  final TodoDatabase _database;
  final Connectivity _connectivity;

  TodoRepository({
    required TodoApi api,
    required TodoDatabase database,
    Connectivity? connectivity,
  })  : _api = api,
        _database = database,
        _connectivity = connectivity ?? Connectivity();

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<List<Todo>> getTodos() async {
    if (await _isOnline()) {
      try {
        final todos = await _api.getTodos();
        await _database.saveTodos(todos);
        return todos;
      } catch (e) {
        // If API fails, return from local storage
        return _database.getTodos();
      }
    } else {
      return _database.getTodos();
    }
  }

  Future<Todo> createTodo(Todo todo) async {
    // Optimistic Update: Save to local first
    final localTodo = todo.copyWith(isLocalOnly: true);
    await _database.saveTodo(localTodo);

    if (await _isOnline()) {
      try {
        final newTodo = await _api.createTodo(todo);
        // Remove local only and save the one from API
        await _database.deleteTodo(todo.localId);
        await _database.saveTodo(newTodo);
        return newTodo;
      } catch (e) {
        return localTodo;
      }
    }
    return localTodo;
  }

  Future<Todo> updateTodo(Todo todo) async {
    // Optimistic Update
    await _database.saveTodo(todo);

    if (await _isOnline() && !todo.isLocalOnly) {
      try {
        final updatedTodo = await _api.updateTodo(todo);
        await _database.saveTodo(updatedTodo);
        return updatedTodo;
      } catch (e) {
        return todo;
      }
    }
    return todo;
  }

  Future<void> deleteTodo(Todo todo) async {
    // Optimistic Update
    final key = todo.id ?? todo.localId;
    await _database.deleteTodo(key);

    if (await _isOnline() && !todo.isLocalOnly) {
      try {
        await _api.deleteTodo(todo.id!);
      } catch (e) {
        // Optionally handle error (e.g., keep in sync queue)
      }
    }
  }

  Future<void> syncPendingTodos() async {
    if (!await _isOnline()) return;

    final allTodos = _database.getTodos();
    final pendingTodos = allTodos.where((t) => t.isLocalOnly).toList();

    for (var todo in pendingTodos) {
      try {
        final syncedTodo = await _api.createTodo(todo);
        await _database.deleteTodo(todo.localId);
        await _database.saveTodo(syncedTodo);
      } catch (e) {
        // Log error or retry later
      }
    }
  }
}
