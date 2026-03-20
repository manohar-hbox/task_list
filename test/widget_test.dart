import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_list/data/repositories/todo_repository.dart';
import 'package:task_list/main.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoRepository();
    // Provide a default empty list to avoid crashes during initial build
    when(() => mockRepository.getTodos()).thenAnswer((_) async => []);
  });

  testWidgets(
      'App shows Login screen initially and navigates to Home on success',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(todoRepository: mockRepository));

    // 1. Verify that we are on the Login screen (Task Master)
    expect(find.text('Task Master'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // 2. Enter credentials
    await tester.enterText(find.byType(TextFormField).first, 'admin');
    await tester.enterText(find.byType(TextFormField).last, 'admin123');

    // 3. Tap Sign In button
    await tester.tap(find.text('Sign In'));

    // AuthBloc has a 1-second mock delay
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // 4. Verify that we are now on the Home screen (My Tasks)
    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('New Task'), findsOneWidget);
  });
}
