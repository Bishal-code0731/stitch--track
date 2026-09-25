import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/account_profile_screen.dart';
import '../../features/auth/presentation/screens/branch_selector_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/language_settings_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/two_factor_enabled_screen.dart';
import '../../features/auth/presentation/screens/two_factor_screen.dart';
import '../../features/auth/presentation/screens/two_factor_setup_screen.dart';
import '../../features/auth/presentation/screens/two_factor_verify_screen.dart';
import '../../features/auth/presentation/screens/welcome_redirect_screen.dart';
import '../../features/counter_workflow/presentation/screens/counter_shell_screen.dart';
import '../../features/customers/presentation/screens/add_customer_screen.dart';
import '../../features/dashboard/presentation/screens/admin_shell_screen.dart';
import '../../features/orders/presentation/screens/new_order_customer_screen.dart';
import '../../features/orders/presentation/screens/new_order_garments_screen.dart';
import '../../features/orders/presentation/screens/new_order_measurements_screen.dart';
import '../../features/orders/presentation/screens/new_order_review_screen.dart';
import '../../features/production_workflow/presentation/screens/production_shell_screen.dart';

/// Route path constants — reference these, never raw path strings.
abstract final class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String twoFactorPattern = '/2fa/:userId';
  static String twoFactor(String userId) => '/2fa/$userId';
  static const String welcome = '/welcome';
  static const String branchSelector = '/branch-selector';
  static const String languageSettings = '/language-settings';
  static const String account = '/account';
  static const String twoFactorSetup = '/2fa-setup';
  static const String twoFactorVerifyPattern = '/2fa-verify/:method';
  static String twoFactorVerify(String method) => '/2fa-verify/$method';
  static const String twoFactorEnabled = '/2fa-enabled';
  static const String admin = '/admin';
  static const String counter = '/counter';
  static const String production = '/production';
  static const String newOrder = '/new-order';
  static const String newOrderGarments = '/new-order/garments';
  static const String newOrderMeasurements = '/new-order/measurements';
  static const String newOrderReview = '/new-order/review';
  static const String addCustomer = '/add-customer';
}

/// Maps a resolved `AuthUser.roleName` to its role shell route.
String shellRouteForRole(String roleName) {
  switch (roleName) {
    case 'Admin':
      return Routes.admin;
    case 'Counter':
      return Routes.counter;
    case 'Production Worker':
      return Routes.production;
    default:
      return Routes.login;
  }
}

/// Auth-entry routes reachable while logged **out** (or mid-login).
bool _isAuthEntry(String loc) =>
    loc == Routes.splash ||
    loc == Routes.login ||
    loc == Routes.register ||
    loc == Routes.forgotPassword ||
    loc.startsWith('/2fa/');

@visibleForTesting
String? guardRedirect({
  required bool sessionLoading,
  required AuthUser? user,
  required String location,
}) {
  if (sessionLoading) return null; // restoring — Splash handles routing

  if (user == null) {
    return _isAuthEntry(location) ? null : Routes.login;
  }

  // Signed in: the pure auth-entry screens no longer make sense.
  if (location == Routes.login ||
      location == Routes.register ||
      location == Routes.forgotPassword) {
    return Routes.welcome;
  }

  // Role-scoped shells: only your own is reachable.
  const shells = {Routes.admin, Routes.counter, Routes.production};
  if (shells.contains(location)) {
    final own = shellRouteForRole(user.roleName);
    if (location != own) return own;
  }
  return null;
}

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(WidgetRef ref) {
    _sub = ref.listenManual(authSessionProvider, (_, _) => notifyListeners());
  }

  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

/// The last location the router resolved to.
String lastRouterLocation = Routes.splash;

/// Builds a fresh [GoRouter].
GoRouter buildAppRouter({
  required WidgetRef ref,
  required Listenable refresh,
  String? initialLocation,
}) {
  return GoRouter(
    initialLocation: initialLocation ?? lastRouterLocation,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authSessionProvider);
      final target = guardRedirect(
        sessionLoading: authState.isLoading,
        user: authState.value,
        location: state.matchedLocation,
      );
      if (target == null) lastRouterLocation = state.uri.toString();
      return target;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.languageSettings,
        builder: (context, state) => const LanguageSettingsScreen(),
      ),
      GoRoute(
        path: Routes.account,
        builder: (context, state) => const AccountProfileScreen(),
      ),
      GoRoute(
        path: Routes.twoFactorSetup,
        builder: (context, state) => const TwoFactorSetupScreen(),
      ),
      GoRoute(
        path: Routes.twoFactorVerifyPattern,
        builder: (context, state) => TwoFactorVerifyScreen(
          isAuthenticator: state.pathParameters['method'] != 'email',
        ),
      ),
      GoRoute(
        path: Routes.twoFactorEnabled,
        builder: (context, state) => const TwoFactorEnabledScreen(),
      ),
      GoRoute(
        path: Routes.twoFactorPattern,
        builder: (context, state) =>
            TwoFactorScreen(userId: state.pathParameters['userId']!),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeRedirectScreen(),
      ),
      GoRoute(
        path: Routes.branchSelector,
        builder: (context, state) => const BranchSelectorScreen(),
      ),
      GoRoute(
        path: Routes.admin,
        builder: (context, state) => const AdminShellScreen(),
      ),
      GoRoute(
        path: Routes.counter,
        builder: (context, state) => const CounterShellScreen(),
      ),
      GoRoute(
        path: Routes.production,
        builder: (context, state) => const ProductionShellScreen(),
      ),
      GoRoute(
        path: Routes.newOrder,
        builder: (context, state) => const NewOrderCustomerScreen(),
      ),
      GoRoute(
        path: Routes.newOrderGarments,
        builder: (context, state) => const NewOrderGarmentsScreen(),
      ),
      GoRoute(
        path: Routes.newOrderMeasurements,
        builder: (context, state) => const NewOrderMeasurementsScreen(),
      ),
      GoRoute(
        path: Routes.newOrderReview,
        builder: (context, state) => const NewOrderReviewScreen(),
      ),
      GoRoute(
        path: Routes.addCustomer,
        builder: (context, state) => const AddCustomerScreen(),
      ),
    ],
  );
}
