import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class TodoApi {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Todo>> getTodos() async {
    final response = await http.get(Uri.parse('$_baseUrl/todos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<Todo> createTodo(Todo todo) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/todos'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(todo.toJson()),
    );

    if (response.statusCode == 201) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create todo');
    }
  }

  Future<Todo> updateTodo(Todo todo) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/todos/${todo.id}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(todo.toJson()),
    );

    if (response.statusCode == 200) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update todo');
    }
  }

  Future<void> deleteTodo(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/todos/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo');
    }
  }
}
