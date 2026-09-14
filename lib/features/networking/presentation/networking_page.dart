import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/core/widgets/app_states.dart';
import 'package:adp_mobile/core/widgets/adp_feedback.dart';
import 'package:adp_mobile/features/networking/presentation/networking_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkingPage extends StatelessWidget {
  const NetworkingPage({super.key});

  @override
  Widget build(BuildContext context) => BlocConsumer<NetworkingCubit, NetworkingState>(
        listenWhen: (previous, current) => previous.actionMessage != current.actionMessage || previous.message != current.message,
        listener: (context, state) {
          final text = state.actionMessage ?? state.message;
          if (text != null) {
            if (state.message != null) {
              AdpFeedback.failure(context, source: 'Réseau', message: text);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
            }
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: AdpColors.canvas,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const AdpStudioBackButton(),
            title: const Text('Annuaire Réseau'),
          ),
          body: _Directory(state: state),
        ),
      );
}

class _Directory extends StatefulWidget {
  const _Directory({required this.state});
  final NetworkingState state;

  @override
  State<_Directory> createState() => _DirectoryState();
}

class _DirectoryState extends State<_Directory> {
  String _searchQuery = '';
  final Set<String> _sentRequests = {};

  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoading && widget.state.data == null) {
      return const AppLoading();
    }
    if (widget.state.status == AsyncStatus.failure && widget.state.data == null) {
      return AppMessage(
        title: 'Annuaire indisponible',
        message: widget.state.message ?? 'Réessayez dans quelques instants.',
        onRetry: context.read<NetworkingCubit>().load,
      );
    }

    final members = (widget.state.data ?? const <NetworkingProfile>[])
        .map(_memberFromProfile)
        .toList(growable: false);
    if (members.isEmpty) {
      return const AppMessage(
        title: 'Un annuaire à votre mesure',
        message: 'Les membres qui choisissent d’être visibles apparaîtront ici.',
      );
    }

    final filtered = members.where((m) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return m.name.toLowerCase().contains(q) ||
          m.role.toLowerCase().contains(q) ||
          m.location.toLowerCase().contains(q) ||
          m.skills.any((s) => s.toLowerCase().contains(q));
    }).toList();

    return RefreshIndicator(
      onRefresh: context.read<NetworkingCubit>().load,
      color: AdpColors.sandGold,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
        children: [
          // ── Header Text (Studio Copy) ──
          const Text(
            'Des synergies concrètes pour Djerba.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AdpColors.ink),
          ),
          const SizedBox(height: 4),
          const Text(
            'Connectez-vous avec les talents, entrepreneurs et investisseurs de la diaspora insulaire.',
            style: TextStyle(fontSize: 13, color: AdpColors.muted, height: 1.4),
          ),
          const SizedBox(height: 16),

          // ── RGPD Opt-in Visibility Card ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AdpColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AdpColors.ink.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: AdpColors.ink.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: widget.state.directoryVisible,
              activeTrackColor: AdpColors.ocean,
              onChanged: context.read<NetworkingCubit>().updateVisibility,
              title: const Text(
                'Visibilité dans l\'annuaire',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AdpColors.ink),
              ),
              subtitle: const Text(
                'Option strictement consentie (RGPD). Votre email reste protégé.',
                style: TextStyle(fontSize: 11.5, color: AdpColors.muted),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Search Input ──
          Container(
            decoration: BoxDecoration(
              color: AdpColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AdpColors.ink.withValues(alpha: 0.08)),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded, color: AdpColors.muted, size: 20),
                hintText: 'Ville, secteur ou compétence (ex: Tech, Paris, Eau...)',
                hintStyle: TextStyle(fontSize: 12.5, color: AdpColors.mutedLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ── Members Section Title ──
          Text(
            '${filtered.length} MEMBRES DISPONIBLES',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AdpColors.terracotta,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),

          // ── Member Cards ──
          ...filtered.map((member) {
            final isSent = _sentRequests.contains(member.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AdpColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AdpColors.ink.withValues(alpha: 0.06)),
                boxShadow: [
                  BoxShadow(
                    color: AdpColors.ink.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFEBF3F5),
                        child: Text(
                          member.initials,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AdpColors.ocean,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AdpColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${member.role} · ${member.location}',
                              style: const TextStyle(fontSize: 12, color: AdpColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Skills Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: member.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AdpColors.canvasSoft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AdpColors.ink.withValues(alpha: 0.04)),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AdpColors.inkSoft),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  // Action CTA
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSent ? AdpColors.canvasSoft : Colors.transparent,
                        foregroundColor: isSent ? AdpColors.muted : AdpColors.ink,
                        side: BorderSide(
                          color: isSent ? Colors.transparent : AdpColors.ink.withValues(alpha: 0.12),
                        ),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      icon: Icon(
                        isSent ? Icons.check_circle_outline_rounded : Icons.send_rounded,
                        size: 15,
                        color: isSent ? AdpColors.success : AdpColors.ink,
                      ),
                      label: Text(
                        isSent ? 'Demande transmise' : 'Prendre contact',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      onPressed: isSent
                          ? null
                          : () {
                              setState(() => _sentRequests.add(member.id));
                              context.read<NetworkingCubit>().requestConnection(member.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Demande de mise en relation transmise à ${member.name}.'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AdpColors.ink,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  _MemberData _memberFromProfile(NetworkingProfile profile) {
    final name = profile.userId.trim().isEmpty ? 'Membre ADP' : profile.userId;
    final initials = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final skills = profile.expertise
        .split('·')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList(growable: false);
    return _MemberData(
      id: profile.userId,
      name: name,
      role: profile.expertise.isEmpty ? 'Membre de la diaspora' : profile.expertise,
      location: profile.city.isEmpty ? 'Localisation non renseignée' : profile.city,
      skills: skills,
      initials: initials.isEmpty ? 'AD' : initials,
    );
  }
}

class _MemberData {
  const _MemberData({
    required this.id,
    required this.name,
    required this.role,
    required this.location,
    required this.skills,
    required this.initials,
  });
  final String id;
  final String name;
  final String role;
  final String location;
  final List<String> skills;
  final String initials;
}

