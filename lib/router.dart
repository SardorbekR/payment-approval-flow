import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/features/home/presentation/pages/home_page.dart';
import 'package:payment_approval/features/payments/presentation/pages/payment_details_page.dart';
import 'package:payment_approval/features/payments/presentation/pages/payments_page.dart';
import 'package:payment_approval/features/shared/pages/not_found_page.dart';
import 'package:payment_approval/features/shared/widgets/app_shell.dart';

enum Routes {
  home('/home'),
  payments('/payments'),
  paymentDetails('/payment/:id');

  Routes(this.path);

  final String path;
}

/// Each tab is one page deep. Payment details is a top-level route, so it opens
/// above the tabs like in the wireframe, and back returns to whichever tab
/// opened it.
GoRouter createRouter({required GlobalKey<NavigatorState> navigatorKey}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.home.path,
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(path: '/', redirect: (context, state) => Routes.home.path),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home.path,
                name: Routes.home.name,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            // Built up front so the list is already listening when a payment is
            // approved from another tab, and can scroll to it and highlight it.
            preload: true,
            routes: [
              GoRoute(
                path: Routes.payments.path,
                name: Routes.payments.name,
                builder: (context, state) => const PaymentsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.paymentDetails.path,
        name: Routes.paymentDetails.name,
        builder: (context, state) => PaymentDetailsPage(paymentId: state.pathParameters['id']!),
      ),
    ],
  );
}
