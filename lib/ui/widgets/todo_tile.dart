import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/todo.dart';
import '../../logic/task_bloc.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;

  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.completed ? TextDecoration.lineThrough : null,
          color: todo.isLocalOnly ? Colors.grey : null,
        ),
      ),
      leading: Checkbox(
        value: todo.completed,
        onChanged: (_) {
          context.read<TaskBloc>().add(ToggleTaskCompletion(todo));
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (todo.isLocalOnly)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.cloud_off, size: 16, color: Colors.grey),
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTask(todo));
            },
          ),
        ],
      ),
    );
  }
}
