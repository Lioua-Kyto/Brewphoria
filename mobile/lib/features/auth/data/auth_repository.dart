import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:brewphoria/core/config/app_config.dart';
import 'package:brewphoria/core/errors/app_exception.dart';
import 'package:brewphoria/core/mock/mock_data.dart';
import 'package:brewphoria/core/storage/hive_service.dart';
import 'package:brewphoria/features/auth/data/auth_remote_datasource.dart';
import 'package:brewphoria/features/auth/domain/user_model.dart';

class AuthRepository {
  AuthRepository(this._datasource);

  final AuthRemoteDatasource _datasource;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Offline demo: any credentials succeed and sign you in as the demo account,
  // with no Firebase/network involved.
  LoginResponse _mockLogin() => LoginResponse(
        user: UserModel.fromJson(mockUser),
        loyaltySummary: LoyaltySummary(
          currentPoints: mockLoyalty['currentPoints'] as int,
          lifetimePoints: mockLoyalty['lifetimePoints'] as int,
          tier: mockLoyalty['tier'] as String,
        ),
      );

  Future<LoginResponse> signInWithGoogle() async {
    if (AppConfig.useMockData) return _mockLogin();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const UnknownException(message: 'Sign in cancelled.');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) throw const UnauthorizedException();

      return _datasource.login(idToken);
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('[AuthRepository] signInWithGoogle error: $e');
      throw const UnknownException(message: 'Sign in failed. Please try again.');
    }
  }

  Future<LoginResponse> signInWithEmail(String email, String password) async {
    if (AppConfig.useMockData) return _mockLogin();
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) throw const UnauthorizedException();
      return _datasource.login(idToken);
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthRepository] signInWithEmail error: $e');
      throw UnknownException(message: _firebaseAuthMessage(e.code));
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('[AuthRepository] signInWithEmail error: $e');
      throw const UnknownException(message: 'Sign in failed. Please try again.');
    }
  }

  Future<LoginResponse> registerWithEmail(String email, String password) async {
    if (AppConfig.useMockData) return _mockLogin();
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) throw const UnauthorizedException();
      return _datasource.login(idToken);
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthRepository] registerWithEmail error: $e');
      throw UnknownException(message: _firebaseAuthMessage(e.code));
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('[AuthRepository] registerWithEmail error: $e');
      throw const UnknownException(message: 'Registration failed. Please try again.');
    }
  }

  String _firebaseAuthMessage(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password.',
      'invalid-credential' => 'Incorrect email or password.',
      'email-already-in-use' => 'An account already exists with this email.',
      'weak-password' => 'Password must be at least 6 characters.',
      'invalid-email' => 'Please enter a valid email address.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      _ => 'Authentication failed. Please try again.',
    };
  }

  Future<LoginResponse?> restoreSession() async {
    // Demo mode starts signed-out so the login screen is shown; any sign-in
    // then returns the demo account.
    if (AppConfig.useMockData) return null;
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      final idToken = await user.getIdToken();
      if (idToken == null) return null;
      return _datasource.login(idToken);
    } catch (e) {
      debugPrint('[AuthRepository] restoreSession error: $e');
      // Sign out so the router redirects to login and POST /auth/login
      // is called fresh — this creates the Postgres user row if missing.
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        HiveService.clearCart(),
      ]);
      return null;
    }
  }

  Future<void> signOut() async {
    if (AppConfig.useMockData) {
      await HiveService.clearCart();
      return;
    }
    try {
      await _datasource.logout();
    } catch (e) {
      debugPrint('[AuthRepository] logout API error (continuing): $e');
    }
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      HiveService.clearCart(),
    ]);
  }

  Future<void> updateFcmToken(String token) async {
    if (AppConfig.useMockData) return;
    try {
      await _datasource.updateFcmToken(token);
    } catch (e) {
      debugPrint('[AuthRepository] updateFcmToken error: $e');
    }
  }
}
