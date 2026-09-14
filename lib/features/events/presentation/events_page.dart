import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/core/widgets/app_states.dart';
import 'package:adp_mobile/features/events/presentation/events_cubit.dart';
import 'package:adp_mobile/features/notifications/presentation/notification_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AdpColors.canvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const AdpStudioBackButton(),
          title: const Text('Agenda & Rencontres'),
        ),
        body: BlocBuilder<EventsCubit, AsyncState<List<Event>>>(
          builder: (context, state) {
            if (state.isLoading) return const AppLoading();
            if (state.status == AsyncStatus.failure) {
              return AppMessage(
                title: 'Événements indisponibles',
                message: state.message ?? 'Veuillez réessayer ultérieurement.',
                onRetry: context.read<EventsCubit>().load,
              );
            }
            return RefreshIndicator(
              onRefresh: context.read<EventsCubit>().load,
              color: AdpColors.sandGold,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                children: [
                  _SummitHeroCard(onNotify: () => _notify(context)),
                  const SizedBox(height: 24),
                  const Text(
                    'Sessions & Tables Rondes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AdpColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if ((state.data ?? const <Event>[]).isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Les prochaines sessions seront publiées sous peu.',
                          style: TextStyle(color: AdpColors.muted, fontSize: 13),
                        ),
                      ),
                    ),
                  ...?state.data?.map((event) => _EventCard(event: event)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AdpColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.how_to_vote_outlined, color: AdpColors.ocean, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Interactivité en direct',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AdpColors.ink),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Participez aux votes et sondages de l\'Assemblée Générale et posez vos questions aux intervenants en temps réel.',
                          style: TextStyle(fontSize: 12, color: AdpColors.muted, height: 1.4),
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

  void _notify(BuildContext context) {
    final preferences = context.read<NotificationCubit>();
    preferences.update(preferences.state.copyWith(events: true));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Rappels du Sommet activés sur cet appareil.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdpColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SummitHeroCard extends StatelessWidget {
  const _SummitHeroCard({required this.onNotify});
  final VoidCallback onNotify;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF0E2129), Color(0xFF1B3D4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0E2129).withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SOMMET DIASPORA 2026',
                  style: TextStyle(
                    color: AdpColors.sandGold,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'FORUM OFFICIEL',
                    style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '24 — 26 Octobre 2026',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Houmt Souk · Djerba, Tunisie',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AdpColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text(
                      'Voir le Sommet',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                    ),
                    onPressed: () => context.push('/summit'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                  tooltip: 'Activer le rappel',
                  onPressed: onNotify,
                ),
              ],
            ),
          ],
        ),
      );
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy · HH:mm', 'fr_FR');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdpColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.event_note_rounded, color: AdpColors.ocean, size: 22),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AdpColors.ink),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dateFmt.format(event.startsAt),
              style: const TextStyle(fontSize: 11.5, color: AdpColors.terracotta, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              event.location,
              style: const TextStyle(fontSize: 12, color: AdpColors.muted),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AdpColors.muted),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (sheetContext) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AdpColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  event.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AdpColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  '${dateFmt.format(event.startsAt)} · ${event.location}',
                  style: const TextStyle(fontSize: 12.5, color: AdpColors.terracotta, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 13.5, color: AdpColors.ink, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdpColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Ajouté à votre agenda'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: const Text('Ajouter à mon agenda', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
