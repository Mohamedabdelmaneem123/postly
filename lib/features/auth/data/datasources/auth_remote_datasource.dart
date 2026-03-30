import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// NOTE: GoogleSignIn has limited native support on Windows. 
// For a production SaaS, this should be configured for Web/Mobile.
// import 'package:google_sign_in/google_sign_in.dart'; 

import 'package:postly/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  
  Future<UserEntity> loginWithEmail(String email, String password);
  Future<UserEntity> registerWithEmail(String email, String password, String name);
  Future<UserEntity> loginWithGoogle();
  Future<UserEntity> loginWithApple();
  Future<void> sendPasswordReset(String email);
  Future<void> logout();
  Future<UserEntity?> fetchUserProfile(String uid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  Future<UserEntity> _createOrUpdateFirebaseUser(User user, {String? displayName}) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    
    if (doc.exists) {
      return _mapDocumentToEntity(doc);
    } else {
      final newUser = UserEntity(
        id: user.uid,
        email: user.email ?? '',
        name: displayName ?? user.displayName ?? '',
        createdAt: DateTime.now(),
        subscriptionPlan: 'FREE',
        companies: const [],
      );

      await docRef.set({
        'id': newUser.id,
        'email': newUser.email,
        'name': newUser.name,
        'created_at': newUser.createdAt.toIso8601String(),
        'subscription_plan': newUser.subscriptionPlan,
        'companies': newUser.companies,
      });

      return newUser;
    }
  }

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    try {
      final credentials = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credentials.user == null) throw Exception('Login failed');
      return await _createOrUpdateFirebaseUser(credentials.user!);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserEntity> registerWithEmail(String email, String password, String name) async {
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credentials.user == null) throw Exception('Registration failed');
      return await _createOrUpdateFirebaseUser(credentials.user!, displayName: name);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    // Google Sign-In requires platform-specific configuration (Web/Android/iOS)
    throw UnimplementedError('Google Sign-In is not yet configured for this platform.');
  }

  @override
  Future<UserEntity> loginWithApple() async {
    throw UnimplementedError('Apple Sign-In requires further iOS configuration');
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<UserEntity?> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) return _mapDocumentToEntity(doc);
    return null;
  }

  UserEntity _mapDocumentToEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserEntity(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at']) ?? DateTime.now()
          : DateTime.now(),
      subscriptionPlan: data['subscription_plan'] ?? 'FREE',
      companies: List<String>.from(data['companies'] ?? []),
    );
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No user found for that email.';
      case 'wrong-password': return 'Wrong password provided.';
      case 'email-already-in-use': return 'The account already exists for that email.';
      case 'invalid-email': return 'The email address is invalid.';
      case 'user-disabled': return 'This user has been disabled.';
      default: return e.message ?? 'Authentication error occurred.';
    }
  }
}
