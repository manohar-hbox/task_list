import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/task_bloc.dart';
import '../../logic/auth_bloc.dart';
import '../widgets/todo_tile.dart';
import '../widgets/add_todo_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;
    final username = authState is Authenticated ? authState.username : 'User';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Elegant App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: theme.primaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'My Tasks',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 4)
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8)
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 60,
                      right: -20,
                      child: Icon(Icons.task_alt,
                          size: 150, color: Colors.white.withOpacity(0.1)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $username',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ready to be productive?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.sync_rounded, color: Colors.white),
                tooltip: 'Sync Tasks',
                onPressed: () => context.read<TaskBloc>().add(SyncTasks()),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () =>
                    context.read<AuthBloc>().add(LogoutRequested()),
              ),
            ],
          ),

          // Search Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) =>
                      context.read<TaskBloc>().add(SearchTasks(value)),
                  decoration: InputDecoration(
                    hintText: 'Search your tasks...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon:
                        Icon(Icons.search_rounded, color: theme.primaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ),

          // Task List Section
          BlocConsumer<TaskBloc, TaskState>(
            listener: (context, state) {
              if (state is TaskError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is TaskLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is TaskLoaded) {
                final todos = state.filteredTodos;
                if (todos.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notes_rounded,
                              size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            state.query.isEmpty
                                ? 'Your task list is empty'
                                : 'No tasks match "$state.query"',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return TodoTile(todo: todos[index]);
                    },
                    childCount: todos.length,
                  ),
                );
              }
              return const SliverFillRemaining(child: SizedBox.shrink());
            },
          ),

          // Extra space for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(context),
        backgroundColor: theme.primaryColor,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Task',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AddTodoDialog(),
    );
  }
}
