import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  UserEntity? _cachedUser;

  AuthRepositoryImpl(this._remoteDataSource) {
    _init();
  }

  void _init() async {
    // Try to pre-populate cache from current firebase user if available
    final firebaseUser = _remoteDataSource.currentUser;
    if (firebaseUser != null) {
      try {
        _cachedUser = await _remoteDataSource.fetchUserProfile(firebaseUser.uid);
      } catch (_) {
        // Silently fail, listener will pick it up
      }
    }

    // Continuously listen to auth state changes
    authStateChanges.listen((user) {
      _cachedUser = user;
    });
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _cachedUser = null;
        return null;
      }
      try {
        final profile = await _remoteDataSource.fetchUserProfile(firebaseUser.uid);
        _cachedUser = profile;
        return profile;
      } catch (e) {
        _cachedUser = null;
        return null;
      }
    });
  }

  @override
  UserEntity? get currentUser => _cachedUser;

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    final user = await _remoteDataSource.loginWithEmail(email, password);
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserEntity> registerWithEmail(String email, String password, String name) async {
    final user = await _remoteDataSource.registerWithEmail(email, password, name);
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    final user = await _remoteDataSource.loginWithGoogle();
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserEntity> loginWithApple() async {
    final user = await _remoteDataSource.loginWithApple();
    _cachedUser = user;
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _remoteDataSource.sendPasswordReset(email);
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    _cachedUser = null;
  }

  @override
  Future<UserEntity?> fetchUserProfile(String uid) {
    return _remoteDataSource.fetchUserProfile(uid);
  }
}
