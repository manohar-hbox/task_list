import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/todo.dart';
import '../data/repositories/todo_repository.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Todo todo;
  const AddTask(this.todo);

  @override
  List<Object?> get props => [todo];
}

class ToggleTaskCompletion extends TaskEvent {
  final Todo todo;
  const ToggleTaskCompletion(this.todo);

  @override
  List<Object?> get props => [todo];
}

class DeleteTask extends TaskEvent {
  final Todo todo;
  const DeleteTask(this.todo);

  @override
  List<Object?> get props => [todo];
}

class SearchTasks extends TaskEvent {
  final String query;
  const SearchTasks(this.query);

  @override
  List<Object?> get props => [query];
}

class SyncTasks extends TaskEvent {}

// States
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Todo> todos;
  final String query;

  const TaskLoaded({required this.todos, this.query = ''});

  List<Todo> get filteredTodos {
    if (query.isEmpty) return todos;
    return todos.where((t) => t.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  List<Object?> get props => [todos, query];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TodoRepository _repository;

  TaskBloc({required TodoRepository repository})
      : _repository = repository,
        super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<DeleteTask>(_onDeleteTask);
    on<SearchTasks>(_onSearchTasks);
    on<SyncTasks>(_onSyncTasks);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final todos = await _repository.getTodos();
      emit(TaskLoaded(todos: todos));
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentTodos = (state as TaskLoaded).todos;
      // Optimistic update
      emit(TaskLoaded(todos: [event.todo, ...currentTodos], query: (state as TaskLoaded).query));

      try {
        final newTodo = await _repository.createTodo(event.todo);
        // After successful sync, we update the list (replace optimistic one)
        final updatedTodos = (state as TaskLoaded).todos.map((t) => t.localId == event.todo.localId ? newTodo : t).toList();
        emit(TaskLoaded(todos: updatedTodos, query: (state as TaskLoaded).query));
      } catch (e) {
        // Handle error (optionally revert optimistic change)
      }
    }
  }

  Future<void> _onToggleTaskCompletion(ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final updatedTodo = event.todo.copyWith(completed: !event.todo.completed);
      final currentTodos = (state as TaskLoaded).todos.map((t) => t == event.todo ? updatedTodo : t).toList();
      emit(TaskLoaded(todos: currentTodos, query: (state as TaskLoaded).query));

      try {
        await _repository.updateTodo(updatedTodo);
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentTodos = (state as TaskLoaded).todos.where((t) => t != event.todo).toList();
      emit(TaskLoaded(todos: currentTodos, query: (state as TaskLoaded).query));

      try {
        await _repository.deleteTodo(event.todo);
      } catch (e) {
        // Handle error
      }
    }
  }

  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      emit(TaskLoaded(todos: (state as TaskLoaded).todos, query: event.query));
    }
  }

  Future<void> _onSyncTasks(SyncTasks event, Emitter<TaskState> emit) async {
    await _repository.syncPendingTodos();
    add(LoadTasks()); // Reload from DB after sync
  }
}
