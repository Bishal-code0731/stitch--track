import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/utils/password_hasher.dart';
import '../../../../core/utils/password_strength.dart';
import '../../domain/auth_exceptions.dart';
import '../../domain/entities/auth_login_result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class _CodeEntry {
  _CodeEntry(this.code, this.expiresAt);
  final String code;
  final DateTime expiresAt;
  bool verified = false;
}

/// Local, Drift-backed [AuthRepository].
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(
    this._db,
    this._secureStorage, {
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final SecureStorageService _secureStorage;
  final DateTime Function() _now;
  final Random _random = Random.secure();

  static const accessTokenTtl = Duration(hours: 12);
  static const refreshTokenTtl = Duration(days: 30);
  static const otpTtl = Duration(minutes: 5);

  static const demoInviteCode = 'STITCH2026';

  final Map<String, _CodeEntry> _resetOtpByPhone = {};
  final Map<String, _CodeEntry> _twoFactorCodeByUserId = {};

  String? debugLastOtpFor(String phone) =>
      _resetOtpByPhone[_normalizePhone(phone)]?.code;
  String? debugLastTwoFactorCodeFor(String userId) =>
      _twoFactorCodeByUserId[userId]?.code;

  String _generateCode() => List.generate(6, (_) => _random.nextInt(10)).join();

  String _normalizePhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('+')) return trimmed;
    final digits = trimmed.replaceAll(RegExp(r'\s+'), '');
    if (digits.startsWith('977')) return '+$digits';
    if (digits.startsWith('0')) return '+977${digits.substring(1)}';
    return '+977$digits';
  }

  Future<AuthUser> _toAuthUser(User user) async {
    final role = await _db.roleDao.getById(user.roleId);
    return AuthUser(
      id: user.id,
      name: user.name,
      phone: user.phone,
      username: user.username,
      roleId: user.roleId,
      roleName: role?.name ?? 'Unknown',
      branchIds: user.branchIds,
      status: user.status,
      localePreference: user.localePreference,
    );
  }

  Future<AuthUser> _establishSession(User user) async {
    const uuid = Uuid();
    final accessExp = _now().add(accessTokenTtl);
    final refreshExp = _now().add(refreshTokenTtl);
    await _secureStorage.writeAccessToken(uuid.v4());
    await _secureStorage.writeRefreshToken(uuid.v4());
    await _secureStorage.writeSessionUserId(user.id);
    await _secureStorage.writeAccessExpiresAt(accessExp);
    await _secureStorage.writeRefreshExpiresAt(refreshExp);
    return _toAuthUser(user);
  }

  @override
  Future<AuthLoginResult> login({
    required String identifier,
    required String password,
  }) async {
    final user =
        await _db.userDao.getByUsername(identifier) ??
        await _db.userDao.getByPhone(_normalizePhone(identifier));
    if (user == null || user.passwordHash != hashPassword(password)) {
      throw const InvalidCredentialsException();
    }
    switch (user.status) {
      case UserStatus.pendingApproval:
        throw const AccountNotActiveException(
          'Your account is awaiting owner approval.',
        );
      case UserStatus.inactive:
        throw const AccountNotActiveException(
          'Your account has been deactivated.',
        );
      case UserStatus.active:
        break;
    }

    if (await isTwoFactorEnabled(user.id)) {
      _twoFactorCodeByUserId[user.id] = _CodeEntry(
        _generateCode(),
        _now().add(otpTtl),
      );
      return AuthLoginTwoFactorRequired(user.id);
    }

    return AuthLoginSuccess(await _establishSession(user));
  }

  @override
  Future<AuthUser> verifyTwoFactorCode({
    required String userId,
    required String code,
  }) async {
    final entry = _twoFactorCodeByUserId[userId];
    if (entry == null) throw const InvalidOtpException();
    if (_now().isAfter(entry.expiresAt)) throw const OtpExpiredException();
    if (entry.code != code) throw const InvalidOtpException();
    _twoFactorCodeByUserId.remove(userId);

    final user = await _db.userDao.getById(userId);
    if (user == null) throw const InvalidCredentialsException();
    return _establishSession(user);
  }

  @override
  Future<AuthUser> register({
    required String inviteCode,
    required String name,
    required String phone,
    required String username,
    required String password,
  }) async {
    if (inviteCode != demoInviteCode) {
      throw const InvalidInviteCodeException();
    }
    final normalizedPhone = _normalizePhone(phone);
    if (await _db.userDao.getByUsername(username) != null) {
      throw const UsernameTakenException();
    }
    if (await _db.userDao.getByPhone(normalizedPhone) != null) {
      throw const PhoneAlreadyRegisteredException();
    }
    final strengthError = passwordStrengthError(password);
    if (strengthError != null) throw WeakPasswordException(strengthError);

    final roles = await _db.roleDao.getAll();
    Role? defaultRole;
    for (final r in roles) {
      if (r.name == 'Production Worker') {
        defaultRole = r;
        break;
      }
    }
    defaultRole ??= roles.isNotEmpty ? roles.first : null;
    if (defaultRole == null) {
      throw const AccountNotActiveException(
        'No roles configured yet — contact the shop owner.',
      );
    }

    final id = const Uuid().v4();
    await _db.userDao.insertRow(
      UsersCompanion.insert(
        id: id,
        name: name,
        phone: normalizedPhone,
        username: username,
        roleId: defaultRole.id,
        branchIds: const <String>[],
        status: UserStatus.pendingApproval,
        passwordHash: hashPassword(password),
        localePreference: UserLocale.en,
        createdAt: _now(),
      ),
    );

    final user = await _db.userDao.getById(id);
    return _toAuthUser(user!);
  }

  @override
  Future<void> requestPasswordResetOtp(String phone) async {
    final normalizedPhone = _normalizePhone(phone);
    final user = await _db.userDao.getByPhone(normalizedPhone);
    if (user == null) throw const UserNotFoundException();
    _resetOtpByPhone[normalizedPhone] = _CodeEntry(
      _generateCode(),
      _now().add(otpTtl),
    );
  }

  @override
  Future<void> verifyOtp({required String phone, required String otp}) async {
    final entry = _resetOtpByPhone[_normalizePhone(phone)];
    if (entry == null) throw const InvalidOtpException();
    if (_now().isAfter(entry.expiresAt)) throw const OtpExpiredException();
    if (entry.code != otp) throw const InvalidOtpException();
    entry.verified = true;
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    final normalizedPhone = _normalizePhone(phone);
    final entry = _resetOtpByPhone[normalizedPhone];
    if (entry == null || !entry.verified) {
      throw const OtpNotVerifiedException();
    }
    final strengthError = passwordStrengthError(newPassword);
    if (strengthError != null) throw WeakPasswordException(strengthError);

    final user = await _db.userDao.getByPhone(normalizedPhone);
    if (user == null) throw const UserNotFoundException();
    await _db.userDao.updateRow(
      user.copyWith(passwordHash: hashPassword(newPassword)),
    );
    _resetOtpByPhone.remove(normalizedPhone);
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final userId = await _secureStorage.readSessionUserId();
    if (userId == null) return null;

    final accessExp = await _secureStorage.readAccessExpiresAt();
    if (accessExp != null && _now().isBefore(accessExp)) {
      final user = await _db.userDao.getById(userId);
      return user == null ? null : _toAuthUser(user);
    }

    final refreshExp = await _secureStorage.readRefreshExpiresAt();
    if (refreshExp != null && _now().isBefore(refreshExp)) {
      final user = await _db.userDao.getById(userId);
      if (user == null) return null;
      return _establishSession(user); // silent refresh
    }

    await _secureStorage.clearSession();
    return null;
  }

  @override
  Future<AuthUser> refreshSession() async {
    final result = await restoreSession();
    if (result == null) throw const SessionExpiredException();
    return result;
  }

  @override
  Future<void> logout() => _secureStorage.clearSession();

  @override
  Future<bool> isTwoFactorEnabled(String userId) async {
    final ids = await _secureStorage.readTwoFactorEnabledUserIds();
    return ids.contains(userId);
  }

  @override
  Future<void> setTwoFactorEnabled(String userId, bool enabled) async {
    final ids = await _secureStorage.readTwoFactorEnabledUserIds();
    if (enabled) {
      ids.add(userId);
    } else {
      ids.remove(userId);
    }
    await _secureStorage.writeTwoFactorEnabledUserIds(ids);
  }
}
