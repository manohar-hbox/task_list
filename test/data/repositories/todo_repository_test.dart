import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:task_list/data/models/todo.dart';
import 'package:task_list/data/providers/todo_api.dart';
import 'package:task_list/data/providers/todo_database.dart';
import 'package:task_list/data/repositories/todo_repository.dart';

class MockTodoApi extends Mock implements TodoApi {}

class MockTodoDatabase extends Mock implements TodoDatabase {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late TodoRepository repository;
  late MockTodoApi mockApi;
  late MockTodoDatabase mockDatabase;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockApi = MockTodoApi();
    mockDatabase = MockTodoDatabase();
    mockConnectivity = MockConnectivity();
    repository = TodoRepository(
      api: mockApi,
      database: mockDatabase,
      connectivity: mockConnectivity,
    );
  });

  final tTodos = [
    const Todo(id: 1, userId: 1, title: 'API Task', completed: false),
  ];

  group('getTodos', () {
    test('returns API todos and saves them when online', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(() => mockApi.getTodos()).thenAnswer((_) async => tTodos);
      when(() => mockDatabase.saveTodos(any())).thenAnswer((_) async {});

      final result = await repository.getTodos();

      expect(result, tTodos);
      verify(() => mockApi.getTodos()).called(1);
      verify(() => mockDatabase.saveTodos(tTodos)).called(1);
    });

    test('returns local todos when offline', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);
      when(() => mockDatabase.getTodos()).thenReturn(tTodos);

      final result = await repository.getTodos();

      expect(result, tTodos);
      verifyZeroInteractions(mockApi);
      verify(() => mockDatabase.getTodos()).called(1);
    });
  });

  group('createTodo', () {
    final tTodo = const Todo(
        userId: 1, title: 'New Task', localId: '123', isLocalOnly: true);

    test('saves to local database and calls API when online', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(() => mockDatabase.saveTodo(any())).thenAnswer((_) async {});
      when(() => mockApi.createTodo(any()))
          .thenAnswer((_) async => tTodo.copyWith(id: 1, isLocalOnly: false));
      when(() => mockDatabase.deleteTodo(any())).thenAnswer((_) async {});

      final result = await repository.createTodo(tTodo);

      expect(result.id, 1);
      expect(result.isLocalOnly, false);
      verify(() => mockDatabase.saveTodo(any()))
          .called(2); // Local first, then API result
      verify(() => mockApi.createTodo(any())).called(1);
      verify(() => mockDatabase.deleteTodo('123')).called(1);
    });
  });
}
