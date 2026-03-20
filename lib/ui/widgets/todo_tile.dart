import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/todo.dart';
import '../../logic/task_bloc.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;

  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.read<TaskBloc>().add(ToggleTaskCompletion(todo));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                // Custom Checkbox
                IconButton(
                  onPressed: () {
                    context.read<TaskBloc>().add(ToggleTaskCompletion(todo));
                  },
                  icon: Icon(
                    todo.completed
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: todo.completed ? Colors.green : Colors.grey[400],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 4),
                // Task Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration: todo.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.completed
                              ? Colors.grey[500]
                              : Colors.black87,
                          fontWeight: todo.completed
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                      if (todo.isLocalOnly)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.cloud_off_rounded,
                                  size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                'Waiting to sync...',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Actions
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: Colors.red[300], size: 24),
                  onPressed: () {
                    _showDeleteConfirmation(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTask(todo));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
