import 'package:adp_mobile/features/auth/presentation/auth_cubit.dart';
import 'package:adp_mobile/features/networking/presentation/networking_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) => cubit.state.session?.user);
    final fullName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Votre profil';
    final email = user?.email ?? 'Compte non connecté';
    final country = user?.country ?? 'COMMUNAUTÉ ADP';

    final initials = fullName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // ── App Bar matching Studio: Left Barlow title + Right circular compass button ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Mon Profil',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: const Color(0xFF0E2129),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Profil synchronisé'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF0E2129),
                        duration: const Duration(seconds: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(color: const Color(0xFFE2DDD3), width: 1.2),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.explore_outlined,
                      size: 17,
                      color: Color(0xFF0E2129),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Avatar: Solid deep black/ink circle with white initials ──
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0E2129),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials.isNotEmpty ? initials : 'SB',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Member Name
                  Text(
                    fullName,
                    style: GoogleFonts.manrope(
                      fontSize: 19.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0E2129),
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Email
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF687B82),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Badges Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ocean badge: current membership tier
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F0F2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'MEMBRE ADP',
                          style: TextStyle(
                            color: Color(0xFF0D6274),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Neutral badge: TUNISIE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFECE5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          country.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF2D424B),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── 4 Option Cards matching the Studio Screenshot exactly ──

            // 1. Visibilité dans l'Annuaire
            BlocBuilder<NetworkingCubit, NetworkingState>(
              builder: (context, netState) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEAE6DE), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Visibilité dans l\'Annuaire',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0E2129),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Visible par les autres membres',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF687B82),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch.adaptive(
                          value: netState.directoryVisible,
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF0D6274),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFDCD8CF),
                          onChanged: (val) {
                            context.read<NetworkingCubit>().updateVisibility(val);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(val ? 'Visible dans l\'annuaire' : 'Masqué de l\'annuaire'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFF0E2129),
                                duration: const Duration(seconds: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // 2. Notifications & Alertes
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push('/notifications'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEAE6DE), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Notifications & Alertes',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0E2129),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '3 non lues',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF687B82),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Color(0xFF687B82),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 3. Exporter mes données (RGPD)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Export RGPD téléchargé : adp_donnees_personnelles.json'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF10B981),
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEAE6DE), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Exporter mes données (RGPD)',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0E2129),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Format JSON conforme art. 20',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF687B82),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.file_download_outlined,
                      size: 18,
                      color: Color(0xFF687B82),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 4. Déconnexion (Soft Terracotta Border + Terracotta Title & Icon)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await context.read<AuthCubit>().logout();
                if (context.mounted) context.go('/auth/login');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x59D46238), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Déconnexion',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD46238),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Quitter la session',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF687B82),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Color(0xFFD46238),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
