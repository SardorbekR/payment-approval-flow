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

/// Payment details sits above the tabs, so back returns to the tab it was opened from
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
            // So Payments can highlight a payment approved from Home
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
