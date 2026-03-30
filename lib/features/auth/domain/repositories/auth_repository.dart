import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
  
  Future<UserEntity> loginWithEmail(String email, String password);
  Future<UserEntity> registerWithEmail(String email, String password, String name);
  Future<UserEntity> loginWithGoogle();
  Future<UserEntity> loginWithApple();
  Future<void> sendPasswordReset(String email);
  Future<void> logout();
  Future<UserEntity?> fetchUserProfile(String uid);
}
