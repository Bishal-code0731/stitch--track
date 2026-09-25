const int kMinPasswordLength = 6;

String? passwordStrengthError(String password) {
  if (password.length < kMinPasswordLength) {
    return 'Password must be at least $kMinPasswordLength characters.';
  }
  return null;
}
