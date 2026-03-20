import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_list/data/models/todo.dart';
import 'package:task_list/data/repositories/todo_repository.dart';
import 'package:task_list/logic/task_bloc.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late TaskBloc taskBloc;
  late MockTodoRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoRepository();
    taskBloc = TaskBloc(repository: mockRepository);
  });

  tearDown(() {
    taskBloc.close();
  });

  final tTodos = [
    const Todo(id: 1, userId: 1, title: 'Test Task 1', completed: false),
    const Todo(id: 2, userId: 1, title: 'Test Task 2', completed: true),
  ];

  test('initial state is TaskInitial', () {
    expect(taskBloc.state, TaskInitial());
  });

  group('LoadTasks', () {
    test('emits [TaskLoading, TaskLoaded] when repository returns todos', () async {
      when(() => mockRepository.getTodos()).thenAnswer((_) async => tTodos);

      taskBloc.add(LoadTasks());

      await expectLater(
        taskBloc.stream,
        emitsInOrder([
          TaskLoading(),
          TaskLoaded(todos: tTodos),
        ]),
      );
    });

    test('emits [TaskLoading, TaskError] when repository fails', () async {
      when(() => mockRepository.getTodos()).thenThrow(Exception('Failed to load'));

      taskBloc.add(LoadTasks());

      await expectLater(
        taskBloc.stream,
        emitsInOrder([
          TaskLoading(),
          const TaskError('Failed to load tasks: Exception: Failed to load'),
        ]),
      );
    });
  });

  group('AddTask', () {
    final newTodo = const Todo(userId: 1, title: 'New Task', localId: '123', isLocalOnly: true);

    test('emits TaskLoaded with new todo immediately (optimistic update)', () async {
      // Mock initial state as Loaded
      when(() => mockRepository.getTodos()).thenAnswer((_) async => tTodos);
      taskBloc.add(LoadTasks());
      await expectLater(taskBloc.stream, emits(TaskLoaded(todos: tTodos)));

      when(() => mockRepository.createTodo(any())).thenAnswer((_) async => newTodo.copyWith(id: 3, isLocalOnly: false));

      taskBloc.add(AddTask(newTodo));

      // Check if first emitted state contains the new todo (optimistic)
      expect(
        taskBloc.stream,
        emitsThrough(
          predicate<TaskState>((state) {
            if (state is TaskLoaded) {
              return state.todos.any((t) => t.localId == '123');
            }
            return false;
          }),
        ),
      );
    });
  });
}
