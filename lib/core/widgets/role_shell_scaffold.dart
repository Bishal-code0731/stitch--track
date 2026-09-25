import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_router.dart';
import '../theme/colors.dart';
import 'app_top_bar.dart';

/// One tab in a [RoleShellScaffold].
class ShellTab {
  const ShellTab({
    required this.icon,
    required this.label,
    required this.body,
    this.selectedIcon,
    this.ownAppBar = false,
    this.floatingActionButton,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final Widget body;

  final bool ownAppBar;

  /// Floating action button shown only while this tab is active (e.g.
  final Widget? floatingActionButton;
}

class RoleShellScaffold extends StatefulWidget {
  const RoleShellScaffold({required this.title, required this.tabs, super.key});

  final String title;
  final List<ShellTab> tabs;

  @override
  State<RoleShellScaffold> createState() => _RoleShellScaffoldState();
}

class _RoleShellScaffoldState extends State<RoleShellScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = widget.tabs;
    final activeTab = tabs[_index];

    return Scaffold(
      // A tab that draws its own header (e.g.
      appBar: activeTab.ownAppBar
          ? null
          : AppTopBar(
              title: widget.title,
              subtitle: activeTab.label,
              showBack: true,
              actions: [
                // Entry point to the personal Account/Profile screen (its logout lives there).
                IconButton(
                  onPressed: () => context.push(Routes.account),
                  icon: const Icon(Icons.account_circle_outlined),
                  color: AppColors.surface,
                  tooltip: 'auth_account_title'.tr(),
                ),
              ],
            ),
      floatingActionButton: activeTab.floatingActionButton,
      body: IndexedStack(
        index: _index,
        children: [for (final tab in tabs) tab.body],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.navy.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.navy : AppColors.mutedText,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.navy : AppColors.mutedText,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final tab in tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon ?? tab.icon),
                label: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder tab body for Phase 00 — real content arrives in later phases.
class ShellTabPlaceholder extends StatelessWidget {
  const ShellTabPlaceholder({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: AppColors.mutedText),
      ),
    );
  }
}
