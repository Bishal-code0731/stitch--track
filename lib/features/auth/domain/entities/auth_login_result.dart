import 'auth_user.dart';

sealed class AuthLoginResult {
  const AuthLoginResult();
}

class AuthLoginSuccess extends AuthLoginResult {
  const AuthLoginSuccess(this.user);
  final AuthUser user;
}

class AuthLoginTwoFactorRequired extends AuthLoginResult {
  const AuthLoginTwoFactorRequired(this.userId);
  final String userId;
}
