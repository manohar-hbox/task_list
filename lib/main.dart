import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/providers/todo_api.dart';
import 'data/providers/todo_database.dart';
import 'data/repositories/todo_repository.dart';
import 'logic/auth_bloc.dart';
import 'logic/task_bloc.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final todoApi = TodoApi();
  final todoDatabase = TodoDatabase();
  await todoDatabase.init();
  
  final todoRepository = TodoRepository(api: todoApi, database: todoDatabase);

  runApp(MyApp(todoRepository: todoRepository));
}

class MyApp extends StatelessWidget {
  final TodoRepository todoRepository;

  const MyApp({super.key, required this.todoRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(
          create: (context) => TaskBloc(repository: todoRepository)..add(LoadTasks()),
        ),
      ],
      child: MaterialApp(
        title: 'Task List App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
