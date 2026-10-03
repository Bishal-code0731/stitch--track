import '../entities/auth_login_result.dart';
import '../entities/auth_user.dart';

/// Auth + session lifecycle.
abstract interface class AuthRepository {
  /// Authenticates by phone **or** username + password.
  Future<AuthLoginResult> login({
    required String identifier,
    required String password,
  });

  /// Completes a login that returned [AuthLoginTwoFactorRequired].
  Future<AuthUser> verifyTwoFactorCode({
    required String userId,
    required String code,
  });

  /// Creates a `pending_approval` staff account gated by a shop invite code.
  Future<AuthUser> register({
    required String inviteCode,
    required String name,
    required String phone,
    required String username,
    required String password,
  });

  /// "Sends" a password-reset OTP to [phone] (simulated — no real SMS before Phase 09).
  Future<void> requestPasswordResetOtp(String phone);

  /// Verifies the OTP sent for [phone].
  Future<void> verifyOtp({required String phone, required String otp});

  /// Sets a new password for [phone] after a successful [verifyOtp].
  Future<void> resetPassword({
    required String phone,
    required String newPassword,
  });

  /// Attempts to restore a session from stored tokens (silent, for Splash).
  Future<AuthUser?> restoreSession();

  /// Forces a token refresh.
  Future<AuthUser> refreshSession();

  /// Clears the stored session.
  Future<void> logout();

  /// Whether [userId] has opted into Two-Factor Auth.
  Future<bool> isTwoFactorEnabled(String userId);

  Future<void> setTwoFactorEnabled(String userId, bool enabled);
}
