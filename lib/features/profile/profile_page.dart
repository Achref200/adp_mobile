import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/features/auth/presentation/auth_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart' show MembershipStatus;
import 'package:adp_mobile/features/membership/presentation/membership_cubit.dart';
import 'package:adp_mobile/features/networking/presentation/networking_cubit.dart';
import 'package:adp_mobile/features/notifications/presentation/inbox_cubit.dart';
import 'package:adp_mobile/features/profile/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) => cubit.state.session?.user);
    final fullName =
        user?.fullName.isNotEmpty == true ? user!.fullName : 'Votre profil';
    final email = user?.email ?? 'Compte non connecté';
    final country = user?.country ?? 'COMMUNAUTÉ ADP';

    final initials = fullName
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join();

    return Scaffold(
      backgroundColor: AdpColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mon Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // ── Identity header ──
          Center(
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AdpColors.tealDeep,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AdpColors.tealDeep.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials.isNotEmpty ? initials : 'AD',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  fullName,
                  style: GoogleFonts.manrope(
                    fontSize: 19.5,
                    fontWeight: FontWeight.w800,
                    color: AdpColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AdpColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AdpColors.tealDeep.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'MEMBRE ADP',
                        style: TextStyle(
                          color: AdpColors.tealDeep,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AdpColors.ink.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        country.toUpperCase(),
                        style: const TextStyle(
                          color: AdpColors.inkSoft,
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
          const SizedBox(height: 24),

          // ── Membership card (real status from MembershipCubit) ──
          const _MembershipCard(),
          const SizedBox(height: 12),

          // ── Notifications summary (real unread count) ──
          const _NotificationsCard(),
          const SizedBox(height: 12),

          // ── Directory visibility (wired to NetworkingCubit) ──
          const _DirectoryVisibilityCard(),
          const SizedBox(height: 12),

          // ── RGPD section ──
          const _PrivacySection(),
          const SizedBox(height: 12),

          // ── Legal & compliance ──
          const _LegalSection(),
          const SizedBox(height: 12),

          // ── Session ──
          const _SessionCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Membership status
// ─────────────────────────────────────────────
class _MembershipCard extends StatelessWidget {
  const _MembershipCard();

  static final _statusLabels = {
    MembershipStatus.draft: ('Brouillon', 'Finalisez votre adhésion pour rejoindre l\u2019association.', Icons.edit_note_rounded),
    MembershipStatus.submitted: ('Demande envoyée', 'Votre dossier est en attente de paiement.', Icons.schedule_rounded),
    MembershipStatus.paymentConfirmed: ('Paiement confirmé', 'Votre adhésion est en cours de validation par le bureau.', Icons.hourglass_top_rounded),
    MembershipStatus.pendingReview: ('En revue', 'Le bureau ADP examine votre dossier.', Icons.hourglass_top_rounded),
    MembershipStatus.active: ('Adhésion active', null, Icons.verified_rounded),
    MembershipStatus.rejected: ('Demande refusée', 'Contactez le bureau pour plus d\u2019informations.', Icons.info_outline_rounded),
    MembershipStatus.expired: ('Adhésion expirée', 'Renouvelez votre cotisation pour réactiver vos avantages.', Icons.timer_off_rounded),
  };

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MembershipCubit, MembershipState>(
        builder: (context, state) {
          final membership = state.data;
          final entry = membership == null
              ? null
              : _statusLabels[membership.status];
          final (label, detail, icon) = entry ??
              ('Adhésion', 'Statut indisponible pour le moment.', Icons.badge_outlined);
          final isActive = membership?.status == MembershipStatus.active;
          final expiry = membership?.expiresAt;

          return _Card(
            onTap: () => context.push('/membership/start'),
            child: Row(
              children: [
                _LeadingIcon(
                  icon: icon,
                  background:
                      isActive ? AdpColors.success : AdpColors.tealDeep,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mon Adhésion',
                          style: _titleStyle()),
                      const SizedBox(height: 2),
                      Text(
                        expiry != null && isActive
                            ? '$label · jusqu\u2019au ${DateFormat('dd/MM/yyyy').format(expiry)}'
                            : label,
                        style: _subtitleStyle(),
                      ),
                      if (detail != null) ...[
                        const SizedBox(height: 2),
                        Text(detail, style: _subtitleStyle()),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: AdpColors.muted),
              ],
            ),
          );
        },
      );
}

// ─────────────────────────────────────────────
// Notifications summary with live unread count
// ─────────────────────────────────────────────
class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<InboxCubit, InboxState>(builder: (context, state) {
        final unread = state.unreadCount;
        return _Card(
          onTap: () => context.push('/notifications'),
          child: Row(
            children: [
              _LeadingIcon(
                icon: Icons.notifications_none_rounded,
                background: AdpColors.tealDeep,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notifications & Alertes', style: _titleStyle()),
                    const SizedBox(height: 2),
                    Text(
                      unread > 0
                          ? '$unread non lue${unread > 1 ? 's' : ''}'
                          : 'Vous êtes à jour',
                      style: _subtitleStyle(),
                    ),
                  ],
                ),
              ),
              if (unread > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AdpColors.terracotta,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$unread',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                )
              else
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: AdpColors.muted),
            ],
          ),
        );
      });
}

// ─────────────────────────────────────────────
// Directory visibility toggle
// ─────────────────────────────────────────────
class _DirectoryVisibilityCard extends StatelessWidget {
  const _DirectoryVisibilityCard();

  @override
  Widget build(BuildContext context) => _Card(
        child: Row(
          children: [
            const _LeadingIcon(
              icon: Icons.people_outline_rounded,
              background: AdpColors.tealDeep,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Visibilité dans l'Annuaire", style: _titleStyle()),
                  const SizedBox(height: 2),
                  Text('Visible par les autres membres',
                      style: _subtitleStyle()),
                ],
              ),
            ),
            BlocBuilder<NetworkingCubit, NetworkingState>(
              builder: (context, netState) => Transform.scale(
                scale: 0.85,
                child: Switch.adaptive(
                  value: netState.directoryVisible,
                  onChanged: (val) {
                    context
                        .read<NetworkingCubit>()
                        .updateVisibility(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val
                            ? "Visible dans l'annuaire"
                            : 'Masqué de l\u2019annuaire'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AdpColors.ink,
                        duration: const Duration(seconds: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// RGPD section: export + erasure
// ─────────────────────────────────────────────
class _PrivacySection extends StatelessWidget {
  const _PrivacySection();

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ProfileCubit, ProfileActionState>(
        listener: (context, state) {
          if (state.status == ProfileActionStatus.success &&
              state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AdpColors.success,
            ));
          } else if (state.status == ProfileActionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message ?? 'Une erreur est survenue.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AdpColors.terracotta,
            ));
          }
        },
        builder: (context, state) {
          final running = state.status == ProfileActionStatus.running;
          return Column(
            children: [
              _Card(
                onTap: running ? null : () => _confirmExport(context),
                child: Row(
                  children: [
                    const _LeadingIcon(
                      icon: Icons.file_download_outlined,
                      background: AdpColors.tealDeep,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Exporter mes données (RGPD)',
                              style: _titleStyle()),
                          const SizedBox(height: 2),
                          Text(
                            state.status == ProfileActionStatus.success &&
                                    state.summary.isNotEmpty
                                ? state.summary.entries
                                    .map((e) => '${e.value} ${e.key}')
                                    .join(' · ')
                                : 'Conforme art. 20 — résumé de vos données',
                            style: _subtitleStyle(),
                          ),
                          if (state.generatedAt != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Généré le ${DateFormat('dd/MM/yyyy à HH:mm').format(state.generatedAt!)}',
                              style: _subtitleStyle(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (running)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AdpColors.tealDeep),
                      )
                    else
                      const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: AdpColors.muted),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Card(
                onTap: running ? null : () => _confirmErasure(context),
                borderColor: AdpColors.terracotta.withValues(alpha: 0.45),
                child: Row(
                  children: [
                    const _LeadingIcon(
                      icon: Icons.delete_sweep_outlined,
                      background: AdpColors.terracotta,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Supprimer mon compte',
                              style: GoogleFonts.manrope(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AdpColors.terracotta)),
                          const SizedBox(height: 2),
                          Text(
                            'Demande d\u2019effacement — traitée sous 30 jours (art. 17)',
                            style: _subtitleStyle(),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: AdpColors.muted),
                  ],
                ),
              ),
            ],
          );
        },
      );

  void _confirmExport(BuildContext context) {
    context.read<ProfileCubit>().exportData();
  }

  void _confirmErasure(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer mon compte ?'),
        content: const Text(
          'Votre demande d\u2019effacement sera transmise au bureau de l\u2019association. '
          'Vos données personnelles seront supprimées sous 30 jours, hors données '
          'comptables que la loi nous oblige à conserver.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AdpColors.terracotta),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProfileCubit>().requestErasure();
            },
            child: const Text('Confirmer la demande'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Legal & compliance
// ─────────────────────────────────────────────
class _LegalSection extends StatelessWidget {
  const _LegalSection();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _Card(
            onTap: () => context.push('/legal/terms'),
            child: Row(
              children: [
                const _LeadingIcon(
                  icon: Icons.gavel_outlined,
                  background: AdpColors.tealDeep,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Conditions Générales', style: _titleStyle()),
                      const SizedBox(height: 2),
                      Text("Règlement et conditions d'utilisation de l'app",
                          style: _subtitleStyle()),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: AdpColors.muted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            onTap: () => context.push('/legal/privacy'),
            child: Row(
              children: [
                const _LeadingIcon(
                  icon: Icons.shield_outlined,
                  background: AdpColors.tealDeep,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Politique de Confidentialité',
                          style: _titleStyle()),
                      const SizedBox(height: 2),
                      Text('Données personnelles, RGPD et cookies',
                          style: _subtitleStyle()),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: AdpColors.muted),
              ],
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────
// Session
// ─────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  const _SessionCard();

  @override
  Widget build(BuildContext context) => _Card(
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Se déconnecter ?'),
              content: const Text(
                  'Votre session sur cet appareil sera fermée. Vos données restent accessibles après reconnexion.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Se déconnecter'),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            await context.read<AuthCubit>().logout();
            if (context.mounted) context.go('/auth/login');
          }
        },
        borderColor: AdpColors.terracotta.withValues(alpha: 0.45),
        child: Row(
          children: [
            const _LeadingIcon(
              icon: Icons.logout_rounded,
              background: AdpColors.terracotta,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Déconnexion',
                      style: GoogleFonts.manrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AdpColors.terracotta)),
                  const SizedBox(height: 2),
                  Text('Quitter la session sur cet appareil',
                      style: _subtitleStyle()),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// Shared pieces
// ─────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card(
      {required this.child, this.onTap, this.borderColor});
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Material(
        color: AdpColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: borderColor ?? AdpColors.stroke, width: 1),
            ),
            child: child,
          ),
        ),
      );
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon, required this.background});
  final IconData icon;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: background.withValues(alpha: 0.11),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 19, color: background),
      );
}

TextStyle _titleStyle() => GoogleFonts.manrope(
      fontSize: 14.5,
      fontWeight: FontWeight.w700,
      color: AdpColors.ink,
    );

TextStyle _subtitleStyle() => const TextStyle(
      fontSize: 12,
      color: AdpColors.muted,
      fontWeight: FontWeight.w500,
      height: 1.35,
    );
