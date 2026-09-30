import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Minimal secure key-value contract.
abstract interface class SecureKeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

/// Real implementation backed by `flutter_secure_storage` (Keystore on Android, Keychain on iOS).
class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  FlutterSecureKeyValueStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);
  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _storage.delete(key: key);
  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

class SecureStorageService {
  SecureStorageService(this._store);

  final SecureKeyValueStore _store;

  static const String _kAccessToken = 'access_token';
  static const String _kRefreshToken = 'refresh_token';
  static const String _kBiometricKeyRef = 'biometric_key_ref';
  static const String _kSessionUserId = 'session_user_id';
  static const String _kAccessExpiresAt = 'session_access_expires_at';
  static const String _kRefreshExpiresAt = 'session_refresh_expires_at';
  static const String _kTwoFactorUserIds = 'two_factor_enabled_user_ids';

  Future<String?> readAccessToken() => _store.read(_kAccessToken);
  Future<void> writeAccessToken(String value) =>
      _store.write(_kAccessToken, value);

  Future<String?> readRefreshToken() => _store.read(_kRefreshToken);
  Future<void> writeRefreshToken(String value) =>
      _store.write(_kRefreshToken, value);

  Future<String?> readBiometricKeyRef() => _store.read(_kBiometricKeyRef);
  Future<void> writeBiometricKeyRef(String value) =>
      _store.write(_kBiometricKeyRef, value);

  /// Which user the current session belongs to (Phase 02 auth).
  Future<String?> readSessionUserId() => _store.read(_kSessionUserId);
  Future<void> writeSessionUserId(String value) =>
      _store.write(_kSessionUserId, value);

  /// Access/refresh token expiry, stored as ISO-8601 strings.
  Future<DateTime?> readAccessExpiresAt() async {
    final raw = await _store.read(_kAccessExpiresAt);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> writeAccessExpiresAt(DateTime value) =>
      _store.write(_kAccessExpiresAt, value.toIso8601String());

  Future<DateTime?> readRefreshExpiresAt() async {
    final raw = await _store.read(_kRefreshExpiresAt);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> writeRefreshExpiresAt(DateTime value) =>
      _store.write(_kRefreshExpiresAt, value.toIso8601String());

  /// User ids that have opted into Two-Factor Auth (Step 9).
  Future<Set<String>> readTwoFactorEnabledUserIds() async {
    final raw = await _store.read(_kTwoFactorUserIds);
    if (raw == null) return {};
    return (jsonDecode(raw) as List<dynamic>).cast<String>().toSet();
  }

  Future<void> writeTwoFactorEnabledUserIds(Set<String> ids) =>
      _store.write(_kTwoFactorUserIds, jsonEncode(ids.toList()));

  /// Clears only the session (tokens + user id + expiries) — used on logout.
  Future<void> clearSession() async {
    await _store.delete(_kAccessToken);
    await _store.delete(_kRefreshToken);
    await _store.delete(_kSessionUserId);
    await _store.delete(_kAccessExpiresAt);
    await _store.delete(_kRefreshExpiresAt);
  }

  /// Wipes every secret, including biometric enrollment and 2FA preferences.
  Future<void> clear() => _store.deleteAll();
}

/// App-wide access to the secure storage service.
final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(FlutterSecureKeyValueStore()),
);
