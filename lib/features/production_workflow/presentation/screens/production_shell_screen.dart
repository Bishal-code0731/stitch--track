import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/role_shell_scaffold.dart';
import 'worker_home_screen.dart';

/// Production Worker role shell: Queue / Scan / My work / Profile (see `docs/03-design-system.md`).
class ProductionShellScreen extends StatelessWidget {
  const ProductionShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleShellScaffold(
      title: 'shell_title_production_worker'.tr(),
      tabs: [
        ShellTab(
          // Mockup IcList: a bulleted list.
          icon: Icons.format_list_bulleted,
          label: 'shell_tab_queue'.tr(),
          // Worker Home draws its own navy header (no shared app bar).
          ownAppBar: true,
          body: const WorkerHomeScreen(),
        ),
        ShellTab(
          // Mockup IcScan: a barcode scan frame.
          icon: Icons.qr_code_scanner,
          label: 'shell_tab_scan'.tr(),
          body: ShellTabPlaceholder(label: 'shell_tab_scan'.tr()),
        ),
        ShellTab(
          // Mockup IcCheckSq: a checkmark inside a square.
          icon: Icons.check_box_outlined,
          selectedIcon: Icons.check_box,
          label: 'shell_tab_my_work'.tr(),
          body: ShellTabPlaceholder(label: 'shell_tab_my_work'.tr()),
        ),
        ShellTab(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'shell_tab_profile'.tr(),
          body: ShellTabPlaceholder(label: 'shell_tab_profile'.tr()),
        ),
      ],
    );
  }
}
