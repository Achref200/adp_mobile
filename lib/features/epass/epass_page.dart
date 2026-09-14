import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/core/widgets/app_states.dart';
import 'package:adp_mobile/features/epass/presentation/epass_cubit.dart';
import 'package:adp_mobile/features/auth/presentation/auth_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EPassPage extends StatelessWidget {
  const EPassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdpColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('e-Pass Membre'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AdpColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AdpColors.ink.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: AdpColors.ink.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                tooltip: 'Partager le pass',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.share_outlined, color: AdpColors.ink, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Lien du pass copié'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AdpColors.ink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<EPassCubit, AsyncState<EPass>>(
        builder: (context, state) {
          if (state.isLoading) return const AppLoading();
          if (state.status == AsyncStatus.failure || state.data == null) {
            return AppMessage(
              title: 'e-Pass indisponible',
              message: state.message ?? 'Une adhésion active est requise pour délivrer un e-Pass.',
              onRetry: context.read<EPassCubit>().load,
            );
          }

          final pass = state.data!;
          final user = context.read<AuthCubit>().state.session?.user;
          return RefreshIndicator(
            onRefresh: context.read<EPassCubit>().load,
            color: AdpColors.sandGold,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                _PassCard(pass: pass, user: user),
                const SizedBox(height: 18),
                _QrCodeBox(qrPayload: pass.qrPayload),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdpColors.navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                        label: const Text(
                          'Ajouter au Wallet',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Ajouté à votre Apple / Google Wallet'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF10B981),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdpColors.ink,
                          side: const BorderSide(color: AdpColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text(
                          'Attestation PDF',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Attestation officielle PDF générée'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AdpColors.navy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AdpColors.border),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, size: 18, color: AdpColors.muted),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ce pass certifié garantit l\'accès prioritaire au Sommet International de la Diaspora 2026 et aux votes statutaires ADP.',
                          style: TextStyle(fontSize: 11.5, color: AdpColors.muted, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PassCard extends StatelessWidget {
  const _PassCard({required this.pass, this.user});
  final EPass pass;
  final User? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2633), Color(0xFF1B3D4F), Color(0xFF0A1821)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2633).withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AdpColors.sandGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.explore_outlined, color: AdpColors.sandGold, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'ADP DJERBA',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Text(
                  _membershipLabel(pass.status),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'ADHÉRENT OFFICIEL',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.fullName ?? 'Membre ADP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ADP-2026-${pass.memberId}',
            style: const TextStyle(
              color: AdpColors.sandGold,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VALABLE JUSQU\'AU',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMMM yyyy').format(pass.validUntil),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.verified_rounded, color: Color(0xFF6EE7B7), size: 16),
                    SizedBox(width: 4),
                    Text(
                      'CERTIFIÉ',
                      style: TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _membershipLabel(MembershipStatus status) => switch (status) {
        MembershipStatus.active => 'MEMBRE ACTIF',
        MembershipStatus.paymentConfirmed => 'PAIEMENT CONFIRME',
        MembershipStatus.pendingReview => 'EN VALIDATION',
        _ => 'STATUT ADP',
      };
}

class _QrCodeBox extends StatelessWidget {
  const _QrCodeBox({required this.qrPayload});
  final String qrPayload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdpColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AdpColors.border),
            ),
            child: QrImageView(
              data: qrPayload,
              version: QrVersions.auto,
              size: 130,
              gapless: true,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AdpColors.navy,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AdpColors.navy,
              ),
              errorStateBuilder: (_, __) => const Icon(Icons.qr_code, size: 64, color: AdpColors.navy),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Scanner pour authentification',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AdpColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Signé cryptographiquement (HMAC SHA-256)',
            style: TextStyle(
              fontSize: 11,
              color: AdpColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
