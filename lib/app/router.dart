import 'package:adp_mobile/app/shell.dart';
import 'package:adp_mobile/features/epass/epass_page.dart';
import 'package:adp_mobile/features/donations/presentation/donation_page.dart';
import 'package:adp_mobile/features/events/presentation/events_page.dart';
import 'package:adp_mobile/features/auth/presentation/forgot_password_page.dart';
import 'package:adp_mobile/features/auth/presentation/login_page.dart';
import 'package:adp_mobile/features/auth/presentation/register_page.dart';
import 'package:adp_mobile/features/home/home_page.dart';
import 'package:adp_mobile/features/membership/presentation/membership_page.dart';
import 'package:adp_mobile/features/networking/presentation/networking_page.dart';
import 'package:adp_mobile/features/news/presentation/news_page.dart';
import 'package:adp_mobile/features/notifications/presentation/notifications_page.dart';
import 'package:adp_mobile/features/payments/presentation/payment_return_page.dart';
import 'package:adp_mobile/features/onboarding/onboarding_page.dart';
import 'package:adp_mobile/features/profile/legal_page.dart';
import 'package:adp_mobile/features/profile/profile_page.dart';
import 'package:adp_mobile/features/projects/projects_page.dart';
import 'package:adp_mobile/features/splash/presentation/splash_page.dart';
import 'package:adp_mobile/features/summit/summit_page.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(initialLocation: '/splash', routes: [
  GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
  GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
  GoRoute(path: '/auth/login', builder: (_, __) => const LoginPage()),
  GoRoute(path: '/auth/register', builder: (_, __) => const RegisterPage()),
  GoRoute(
      path: '/auth/forgot-password',
      builder: (_, __) => const ForgotPasswordPage()),
  GoRoute(
      path: '/legal/terms',
      builder: (_, __) => const LegalPage(document: 'terms')),
  GoRoute(
      path: '/legal/privacy',
      builder: (_, __) => const LegalPage(document: 'privacy')),
  GoRoute(
      path: '/legal/data-deletion',
      builder: (_, __) => const LegalPage(document: 'data-deletion')),
  GoRoute(
      path: '/membership/start', builder: (_, __) => const MembershipPage()),
  GoRoute(
      path: '/donate',
      builder: (_, state) => DonationPage(
          projectId: state.uri.queryParameters['projectId'],
          projectName: state.uri.queryParameters['projectName'])),
  GoRoute(
      path: '/payment-return',
      builder: (_, state) => PaymentReturnPage(
          checkoutIntentId: state.uri.queryParameters['checkoutIntentId'],
          providerCode: state.uri.queryParameters['code'])),
  GoRoute(path: '/summit', builder: (_, __) => const SummitPage()),
  GoRoute(path: '/news', builder: (_, __) => const NewsPage()),
  GoRoute(path: '/networking', builder: (_, __) => const NetworkingPage()),
  GoRoute(path: '/events', builder: (_, __) => const EventsPage()),
  GoRoute(
      path: '/notifications', builder: (_, __) => const NotificationsPage()),
  StatefulShellRoute.indexedStack(
    builder: (context, state, shell) => AppShell(shell: shell),
    branches: [
      StatefulShellBranch(routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomePage())
      ]),
      StatefulShellBranch(routes: [
        GoRoute(path: '/projects', builder: (_, __) => const ProjectsPage())
      ]),
      StatefulShellBranch(routes: [
        GoRoute(path: '/epass', builder: (_, __) => const EPassPage())
      ]),
      StatefulShellBranch(routes: [
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage())
      ]),
    ],
  ),
]);
