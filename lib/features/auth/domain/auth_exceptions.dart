sealed class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
    : super('Incorrect phone/username or password.');
}

/// Account exists but isn't active yet (pending owner approval) or was deactivated.
class AccountNotActiveException extends AuthException {
  const AccountNotActiveException(super.detail);
}

class InvalidInviteCodeException extends AuthException {
  const InvalidInviteCodeException() : super('That invite code is not valid.');
}

class UsernameTakenException extends AuthException {
  const UsernameTakenException() : super('That username is already taken.');
}

class PhoneAlreadyRegisteredException extends AuthException {
  const PhoneAlreadyRegisteredException()
    : super('That phone number is already registered.');
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException()
    : super('No account found for that phone number.');
}

class InvalidOtpException extends AuthException {
  const InvalidOtpException() : super('That code is incorrect.');
}

class OtpExpiredException extends AuthException {
  const OtpExpiredException()
    : super('That code has expired. Request a new one.');
}

class OtpNotVerifiedException extends AuthException {
  const OtpNotVerifiedException()
    : super('Verify the code before setting a new password.');
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException(super.detail);
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException()
    : super('Your session has expired. Please log in again.');
}
