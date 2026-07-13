import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:coffee_card/features/auth/data/auth_remote_datasource.dart';
import 'package:coffee_card/features/auth/data/auth_repository.dart';
import 'package:coffee_card/features/auth/domain/user_model.dart';
import 'package:coffee_card/features/auth/presentation/providers/guest_provider.dart';
import 'package:coffee_card/core/storage/hive_service.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(AuthRemoteDatasource());
}

@riverpod
Stream<User?> authState(Ref ref) {
  return FirebaseAuth.instance.authStateChanges();
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<UserModel?> build() {
    // If the app boots with a cached Firebase session, sync with the backend
    // immediately so the Postgres user row is guaranteed to exist.
    Future.microtask(() async {
      if (FirebaseAuth.instance.currentUser != null &&
          state.valueOrNull == null) {
        await restoreSession();
      }
    });
    return const AsyncValue.data(null);
  }

  Stream<User?> authStateChanges() => FirebaseAuth.instance.authStateChanges();

  /// Replace the cached user after a profile edit so the greeting elsewhere
  /// (e.g. Shop header) reflects the new name immediately.
  void setUser(UserModel user) => state = AsyncValue.data(user);

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final loginResponse = await repo.signInWithGoogle();
      return loginResponse.user;
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final loginResponse = await repo.signInWithEmail(email, password);
      return loginResponse.user;
    });
  }

  Future<void> registerWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final loginResponse = await repo.registerWithEmail(email, password);
      return loginResponse.user;
    });
  }

  Future<void> restoreSession() async {
    final repo = ref.read(authRepositoryProvider);
    final loginResponse = await repo.restoreSession();
    if (loginResponse != null) {
      state = AsyncValue.data(loginResponse.user);
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    clearGuestMode();
    // Drop the local cart cache so a later guest session doesn't inherit the
    // signed-out account's items.
    await HiveService.clearCart();
    try {
      await HiveService.userPrefsBox.put(HiveKeys.guestCartPending, false);
    } catch (_) {}
    state = const AsyncValue.data(null);
  }

  Future<void> updateFcmToken(String token) async {
    await ref.read(authRepositoryProvider).updateFcmToken(token);
  }
}
