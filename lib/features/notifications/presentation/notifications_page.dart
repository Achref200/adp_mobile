import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/core/widgets/app_states.dart';
import 'package:adp_mobile/features/notifications/presentation/inbox_cubit.dart';
import 'package:adp_mobile/features/notifications/presentation/notification_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AdpColors.canvas,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const AdpStudioBackButton(),
            title: const Text('Notifications'),
            bottom: TabBar(
              indicatorColor: AdpColors.terracotta,
              indicatorWeight: 2.5,
              labelColor: AdpColors.ink,
              unselectedLabelColor: AdpColors.muted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              tabs: const [Tab(text: 'Réception'), Tab(text: 'Préférences')],
            ),
          ),
          body: const TabBarView(children: [_Inbox(), _Settings()]),
        ),
      );
}

class _Inbox extends StatelessWidget {
  const _Inbox();

  @override
  Widget build(BuildContext context) => BlocBuilder<InboxCubit, AsyncState<List<AppNotification>>>(
        builder: (context, state) {
          if (state.isLoading) return const AppLoading();
          if (state.status == AsyncStatus.failure) {
            return AppMessage(
              title: 'Notifications indisponibles',
              message: state.message ?? 'Veuillez réessayer ultérieurement.',
              onRetry: context.read<InboxCubit>().load,
            );
          }
          final messages = state.data ?? const <AppNotification>[];
          if (messages.isEmpty) {
            return const AppMessage(
              title: 'Aucune notification',
              message: 'Les alertes concernant vos dons, projets et accès apparaîtront ici.',
            );
          }
          return RefreshIndicator(
            onRefresh: context.read<InboxCubit>().load,
            color: AdpColors.sandGold,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _MessageTile(message: messages[index]),
            ),
          );
        },
      );
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});
  final AppNotification message;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AdpColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdpColors.ink.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: AdpColors.ink.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: message.read
                  ? AdpColors.ocean.withValues(alpha: .10)
                  : AdpColors.terracotta.withValues(alpha: .15),
            ),
            child: Icon(
              message.read ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
              color: message.read ? AdpColors.ocean : AdpColors.terracotta,
              size: 20,
            ),
          ),
          title: Text(
            message.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AdpColors.ink),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${message.body}\n${DateFormat('dd MMM · HH:mm', 'fr_FR').format(message.createdAt)}',
              style: const TextStyle(fontSize: 12.5, color: AdpColors.muted, height: 1.4),
            ),
          ),
          isThreeLine: true,
        ),
      );
}

class _Settings extends StatelessWidget {
  const _Settings();

  @override
  Widget build(BuildContext context) => BlocBuilder<NotificationCubit, NotificationPreferences>(
        builder: (context, preferences) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
          children: [
            const Text(
              'Personnaliser mes alertes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AdpColors.ink),
            ),
            const SizedBox(height: 6),
            const Text(
              'Gérez vos préférences de notifications selon vos centres d\'intérêt insulaires.',
              style: TextStyle(fontSize: 13, color: AdpColors.muted, height: 1.4),
            ),
            const SizedBox(height: 18),
            _switch(context, 'Actualités de l\'île', 'Articles, tribunes et communiqués officiels.', preferences.news, (value) => preferences.copyWith(news: value)),
            _switch(context, 'Projets Citoyens', 'Paliers financiers atteints et chantiers participatifs.', preferences.projects, (value) => preferences.copyWith(projects: value)),
            _switch(context, 'Sommet Diaspora & Événements', 'Rappels de conférences, votes en direct et badges.', preferences.events, (value) => preferences.copyWith(events: value)),
            _switch(context, 'Réseau & Mises en relation', 'Demandes de contact reçues de membres de la diaspora.', preferences.networking, (value) => preferences.copyWith(networking: value)),
            _switch(context, 'Adhésions & Dons', 'Reçus fiscaux annuels et attestations de membre.', preferences.membership, (value) => preferences.copyWith(membership: value)),
          ],
        ),
      );

  Widget _switch(
    BuildContext context,
    String label,
    String detail,
    bool value,
    NotificationPreferences Function(bool) next,
  ) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AdpColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdpColors.ink.withValues(alpha: 0.06)),
        ),
        child: SwitchListTile.adaptive(
          activeTrackColor: AdpColors.ocean,
          title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AdpColors.ink)),
          subtitle: Text(detail, style: const TextStyle(fontSize: 12, color: AdpColors.muted)),
          value: value,
          onChanged: (enabled) => context.read<NotificationCubit>().update(next(enabled)),
        ),
      );
}
