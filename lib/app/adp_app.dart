import 'dart:async';
import 'package:adp_mobile/app/router.dart';
import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/app/dependencies.dart';
import 'package:adp_mobile/features/auth/presentation/auth_cubit.dart';
import 'package:adp_mobile/features/projects/presentation/projects_cubit.dart';
import 'package:adp_mobile/features/notifications/presentation/notification_cubit.dart';
import 'package:adp_mobile/features/notifications/presentation/inbox_cubit.dart';
import 'package:adp_mobile/features/news/presentation/news_cubit.dart';
import 'package:adp_mobile/features/events/presentation/events_cubit.dart';
import 'package:adp_mobile/features/membership/presentation/membership_cubit.dart';
import 'package:adp_mobile/features/donations/presentation/donation_cubit.dart';
import 'package:adp_mobile/features/networking/presentation/networking_cubit.dart';
import 'package:adp_mobile/features/epass/presentation/epass_cubit.dart';
import 'package:adp_mobile/features/payments/presentation/payment_status_cubit.dart';
import 'package:adp_mobile/features/profile/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';

class AdpApp extends StatefulWidget {
  const AdpApp({super.key});

  @override
  State<AdpApp> createState() => _AdpAppState();
}

class _AdpAppState extends State<AdpApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _linkSubscription = _appLinks.uriLinkStream.listen(_openLink);
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _openLink(uri);
    });
  }

  void _openLink(Uri uri) {
    final isPaymentReturn = uri.path == '/payment-return' &&
        (uri.scheme == 'adp' || uri.host == 'app.djerbaproject.fr');
    if (isPaymentReturn) {
      appRouter.go(Uri(
        path: '/payment-return',
        queryParameters: uri.queryParameters,
      ).toString());
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) =>
                  AuthCubit(AppDependencies.authRepository())..restore()),
          BlocProvider(
              create: (_) =>
                  ProjectsCubit(AppDependencies.projectRepository())..load()),
          BlocProvider(
              create: (_) =>
                  NewsCubit(AppDependencies.newsRepository())..load()),
          BlocProvider(
              create: (_) =>
                  EventsCubit(AppDependencies.eventRepository())..load()),
          BlocProvider(
              create: (_) =>
                  MembershipCubit(AppDependencies.membershipRepository())
                    ..load()),
          BlocProvider(
              create: (_) => DonationCubit(AppDependencies.donationRepository())
                ..loadHistory()),
          BlocProvider(
              create: (_) =>
                  NetworkingCubit(AppDependencies.networkingRepository())
                    ..load()),
          BlocProvider(
              create: (_) => EPassCubit(AppDependencies.ePassRepository())),
          BlocProvider(create: (_) => NotificationCubit()..restore()),
          BlocProvider(
              create: (_) =>
                  InboxCubit(AppDependencies.notificationRepository())..load()),          BlocProvider(
              create: (_) =>
                  PaymentStatusCubit(
                  AppDependencies.paymentStatusRepository())),
          BlocProvider(
              create: (_) =>
                  ProfileCubit(AppDependencies.privacyRepository())),
        ],
        child: MaterialApp.router(
          title: 'ADP — Association Djerba Project',
          debugShowCheckedModeBanner: false,
          theme: adpTheme(),
          routerConfig: appRouter,
          builder: (context, child) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                final path = appRouter.routeInformationProvider.value.uri.path;
                final requiresAccount = _protectedPaths.contains(path);
                // (Re)load session-scoped data once authentication resolves.
                if (authState.status == AuthStatus.authenticated) {
                  context.read<EPassCubit>().load();
                  context.read<InboxCubit>().load();
                  context.read<MembershipCubit>().load();
                }
                if (requiresAccount && authState.status != AuthStatus.authenticated) {
                  if (authState.status == AuthStatus.unauthenticated || authState.status == AuthStatus.failure) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (appRouter.routeInformationProvider.value.uri.path == path) {
                        appRouter.go('/auth/login');
                      }
                    });
                  }
                  return const Scaffold(
                    backgroundColor: AdpColors.canvas,
                    body: Center(child: CircularProgressIndicator(color: AdpColors.terracotta)),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth <= 480) {
                      return child ?? const SizedBox.shrink();
                    }
                    return _StudioWebFrame(child: child ?? const SizedBox.shrink());
                  },
                );
              },
            );
          },
        ),
      );

  static const _protectedPaths = <String>{
    '/home',
    '/projects',
    '/epass',
    '/profile',
    '/membership/start',
    '/donate',
    '/summit',
    '/news',
    '/networking',
    '/events',
    '/notifications',
    '/payment-return',
  };
}

class _StudioWebFrame extends StatefulWidget {
  const _StudioWebFrame({required this.child});
  final Widget child;

  @override
  State<_StudioWebFrame> createState() => _StudioWebFrameState();
}

class _StudioWebFrameState extends State<_StudioWebFrame> {
  bool _isWide = false;
  String _selectedRoute = '/home';

  static const _screens = [
    MapEntry('/splash', '1. Splash Screen'),
    MapEntry('/onboarding', '2. Onboarding Interactif'),
    MapEntry('/auth/login', '3. Connexion'),
    MapEntry('/auth/register', '4. Inscription'),
    MapEntry('/home', '5. Accueil Dashboard'),
    MapEntry('/projects', '6. Projets Citoyens'),
    MapEntry('/summit', '7. Sommet Diaspora 2026'),
    MapEntry('/epass', '8. e-Pass Membre'),
    MapEntry('/donate', '9. Faire un Don'),
    MapEntry('/membership/start', '10. Adhésion & Cotisation'),
    MapEntry('/networking', '11. Annuaire Réseau'),
    MapEntry('/events', '12. Agenda & Rencontres'),
    MapEntry('/news', '13. Actualités de l\'île'),
    MapEntry('/notifications', '14. Notifications'),
    MapEntry('/profile', '15. Mon Profil & RGPD'),
    MapEntry('/payment-return', '16. Confirmation Paiement'),
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentPath = appRouter.routeInformationProvider.value.uri.path;
    final selectedRoute = _screens.any((entry) => entry.key == currentPath)
        ? currentPath
        : _selectedRoute;

    return Scaffold(
      backgroundColor: const Color(0xFF0C1014),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.7),
            radius: 1.2,
            colors: [Color(0xFF18222B), Color(0xFF0C1014)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top Studio Toolbar (Parity with frontend/serve.js) ──
              Container(
                width: _isWide ? 760 : 390,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.explore_outlined, size: 16, color: AdpColors.sandGold),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'ADP CONGRÈS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Screen Dropdown
                    SizedBox(
                      width: _isWide ? 210 : 190,
                      child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          final currentIndex = _screens.indexWhere((entry) => entry.key == selectedRoute);
                          final next = _screens[(currentIndex + 1) % _screens.length];
                          setState(() => _selectedRoute = next.key);
                          appRouter.go(next.key);
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _screens.firstWhere((entry) => entry.key == selectedRoute).value,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 14),
                          ],
                        ),
                      ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Format Toggle Button
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                        ),
                        padding: const EdgeInsets.all(6),
                        minimumSize: const Size(32, 32),
                      ),
                      icon: const Icon(Icons.devices_rounded, size: 15, color: Colors.white),
                      onPressed: () => setState(() => _isWide = !_isWide),
                    ),
                  ],
                ),
              ),

              // ── Phone Chassis (#app-frame parity) ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: _isWide ? 760 : 390,
                height: 844,
                decoration: BoxDecoration(
                  color: AdpColors.canvas,
                  borderRadius: BorderRadius.circular(_isWide ? 28 : 46),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x8C000000),
                      blurRadius: 70,
                      offset: Offset(0, 24),
                    ),
                    BoxShadow(
                      color: Color(0x14FFFFFF),
                      blurRadius: 1,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Screen Body Content
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: widget.child,
                      ),
                    ),

                    // Top Status Bar Overlay (.status-bar parity)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 44,
                      child: Container(
                        padding: const EdgeInsets.only(left: 26, right: 26, top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AdpColors.ink,
                              ),
                            ),
                            // Dynamic Island / Notch capsule
                            Container(
                              width: 114,
                              height: 26,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111111),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF222222)),
                                    ),
                                  ),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0D1E2B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status Icons
                            const Row(
                              children: [
                                Icon(Icons.signal_cellular_alt_rounded, size: 14, color: AdpColors.ink),
                                SizedBox(width: 4),
                                Icon(Icons.wifi_rounded, size: 14, color: AdpColors.ink),
                                SizedBox(width: 4),
                                Icon(Icons.battery_full_rounded, size: 16, color: AdpColors.ink),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // iOS Home Indicator (.home-indicator parity)
                    Positioned(
                      bottom: 6,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 134,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AdpColors.ink.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
