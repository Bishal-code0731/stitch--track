import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../data/local/local_auth_repository.dart';
import '../../domain/entities/auth_login_result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// The repository screens/providers depend on.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return LocalAuthRepository(db, secureStorage);
});

/// The signed-in user, or `null` if logged out.
class AuthSessionController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() {
    return ref.watch(authRepositoryProvider).restoreSession();
  }

  /// Returns the result so the caller can branch on [AuthLoginTwoFactorRequired] vs [AuthLoginSuccess].
  Future<AuthLoginResult> login({
    required String identifier,
    required String password,
  }) async {
    final result = await ref
        .read(authRepositoryProvider)
        .login(identifier: identifier, password: password);
    if (result is AuthLoginSuccess) {
      state = AsyncData(result.user);
    }
    return result;
  }

  Future<void> completeTwoFactor({
    required String userId,
    required String code,
  }) async {
    final user = await ref
        .read(authRepositoryProvider)
        .verifyTwoFactorCode(userId: userId, code: code);
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionController, AuthUser?>(
      AuthSessionController.new,
    );
