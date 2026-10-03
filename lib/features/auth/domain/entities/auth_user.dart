import '../../../../core/database/enums.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.username,
    required this.roleId,
    required this.roleName,
    required this.branchIds,
    required this.status,
    required this.localePreference,
  });

  final String id;
  final String name;
  final String phone;
  final String username;
  final String roleId;

  /// Resolved `Role.name` at the time of login (e.g.
  final String roleName;

  final List<String> branchIds;
  final UserStatus status;
  final UserLocale localePreference;

  bool get isAdmin => roleName == 'Admin';

  bool get hasMultipleBranches => branchIds.length > 1;
}
