import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final LoginWithEmailUseCase _loginWithEmail;
  final RegisterWithEmailUseCase _registerWithEmail;
  final LoginWithGoogleUseCase _loginWithGoogle;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required AuthRepository authRepository,
    required LoginWithEmailUseCase loginWithEmail,
    required RegisterWithEmailUseCase registerWithEmail,
    required LoginWithGoogleUseCase loginWithGoogle,
    required LogoutUseCase logoutUseCase,
  })  : _authRepository = authRepository,
        _loginWithEmail = loginWithEmail,
        _registerWithEmail = registerWithEmail,
        _loginWithGoogle = loginWithGoogle,
        _logoutUseCase = logoutUseCase,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      // Typically we'd listen to the stream, but for MVP initial check:
      final userStream = _authRepository.authStateChanges;
      userStream.listen((user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      });
    } catch (e) {
      emit(AuthError('Failed to check auth status: $e'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _loginWithEmail(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    try {
      final user = await _registerWithEmail(email, password, name);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _loginWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _logoutUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated()); // Fallback to unauthenticated on logout error
    }
  }
}
