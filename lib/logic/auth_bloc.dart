import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  const LoginRequested(this.username, this.password);
  @override
  List<Object?> get props => [username, password];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String username;
  const Authenticated(this.username);
  @override
  List<Object?> get props => [username];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // Mock delay

    // Hardcoded credentials for mock login
    if (event.username == 'admin' && event.password == 'admin123') {
      emit(Authenticated(event.username));
    } else {
      emit(const AuthError('Invalid username or password'));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(Unauthenticated());
  }
}
