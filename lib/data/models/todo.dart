import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends Equatable {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final int userId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final bool completed;
  @HiveField(4)
  final bool isLocalOnly; // To track locally created but not yet synced tasks
  @HiveField(5)
  final String? localId; // Temporary ID for local tasks

  const Todo({
    this.id,
    required this.userId,
    required this.title,
    this.completed = false,
    this.isLocalOnly = false,
    this.localId,
  });

  Todo copyWith({
    int? id,
    int? userId,
    String? title,
    bool? completed,
    bool? isLocalOnly,
    String? localId,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      localId: localId ?? this.localId,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      userId: json['userId'] ?? 1,
      title: json['title'],
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'completed': completed,
    };
  }

  @override
  List<Object?> get props => [id, userId, title, completed, isLocalOnly, localId];
}
