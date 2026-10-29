import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/role_shell_scaffold.dart';
import 'counter_home_screen.dart';

/// Counter role shell: Home / Orders / Customers / More (see `docs/03-design-system.md`).
class CounterShellScreen extends StatelessWidget {
  const CounterShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleShellScaffold(
      title: 'auth_role_counter_tile'.tr(),
      tabs: [
        ShellTab(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'shell_tab_home'.tr(),
          ownAppBar: true,
          floatingActionButton: const NewOrderFab(),
          body: const CounterHomeScreen(),
        ),
        ShellTab(
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          label: 'shell_tab_orders'.tr(),
          body: ShellTabPlaceholder(label: 'shell_tab_orders'.tr()),
        ),
        ShellTab(
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          label: 'shell_tab_customers'.tr(),
          body: ShellTabPlaceholder(label: 'shell_tab_customers'.tr()),
        ),
        ShellTab(
          icon: Icons.more_horiz,
          label: 'shell_tab_more'.tr(),
          body: ShellTabPlaceholder(label: 'shell_tab_more'.tr()),
        ),
      ],
    );
  }
}
