import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/role_shell_scaffold.dart';

/// Admin role shell: Dashboard / Orders / Staff / Settings (see `docs/03-design-system.md`).
class AdminShellScreen extends StatelessWidget {
  const AdminShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleShellScaffold(
      title: 'auth_role_admin_tile'.tr(),
      tabs: [
        ShellTab(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'shell_tab_dashboard'.tr(),
          body: ShellTabPlaceholder(label: 'shell_tab_dashboard'.tr()),
        ),
        ShellTab(
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          label: 'shell_tab_orders'.tr(),
          body: ShellTabPlaceholder(label: 'shell_tab_orders'.tr()),
        ),
        ShellTab(
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups,
          label: 'shell_tab_staff'.tr(),
          body: ShellTabPlaceholder(label: 'shell_tab_staff'.tr()),
        ),
        ShellTab(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          label: 'shell_tab_settings'.tr(),
          body: ShellTabPlaceholder(label: 'shell_tab_settings'.tr()),
        ),
      ],
    );
  }
}
