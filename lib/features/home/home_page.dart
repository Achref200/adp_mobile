import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/auth/presentation/auth_cubit.dart';
import 'package:adp_mobile/features/donations/presentation/donation_cubit.dart';
import 'package:adp_mobile/features/events/presentation/events_cubit.dart';
import 'package:adp_mobile/features/membership/presentation/membership_cubit.dart';
import 'package:adp_mobile/features/news/presentation/news_cubit.dart';
import 'package:adp_mobile/features/projects/presentation/projects_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                context.read<ProjectsCubit>().load(),
                context.read<NewsCubit>().load(),
                context.read<EventsCubit>().load(),
                context.read<MembershipCubit>().load(),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
              children: [
                // ── Human Header (Avatar + Name + Badge + Actions) ──
                const _HomeHeader(),
                const SizedBox(height: 18),

                // ── 3-Column Impact Stats ──
                const _StatsGrid(),
                const SizedBox(height: 20),

                // ── 4 Direct Action Buttons ──
                const _ActionGrid(),
                const SizedBox(height: 18),

                // ── Summit 2026 Highlight Card ──
                const _SummitCard(),
                const SizedBox(height: 22),

                // ── Featured Project Story ──
                _SectionBar(
                  heading: 'Projet Prioritaire',
                  linkText: 'Tous les projets',
                  onLinkTap: () => context.push('/projects'),
                ),
                const SizedBox(height: 10),
                BlocBuilder<ProjectsCubit, ProjectsState>(
                  builder: (context, state) {
                    if (state.items.isEmpty) {
                      return const _QuietState(text: 'Les projets publiés apparaîtront ici.');
                    }
                    return _ProjectStoryCard(project: state.items.first);
                  },
                ),
                const SizedBox(height: 22),

                // ── Latest News Dispatches ──
                _SectionBar(
                  heading: 'Nouvelles de Djerba',
                  linkText: 'Archives',
                  onLinkTap: () => context.push('/news'),
                ),
                const SizedBox(height: 10),
                BlocBuilder<NewsCubit, AsyncState<List<News>>>(
                  builder: (context, state) {
                    final articles = state.data ?? [];
                    if (articles.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: articles.take(2).map((n) => _NewsCard(article: n)).toList(),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// Human Header: Avatar initials + verified badge
// ─────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.session?.user;
    final firstName = user?.firstName ?? 'Membre';
    final lastName = user?.lastName ?? 'ADP';
    final country = user?.country ?? 'Votre communauté';
    final initials = '${firstName.isNotEmpty ? firstName[0] : 'S'}${lastName.isNotEmpty ? lastName[0] : 'B'}';

    return Row(
      children: [
        // Avatar circle with initials
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AdpColors.ink,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$firstName $lastName',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.verified, size: 15, color: AdpColors.ocean),
                ],
              ),
              Text(
                'Membre ADP · $country',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AdpColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Notification bell
        _IconBtn(
          icon: Icons.notifications_none_rounded,
          onTap: () => context.push('/notifications'),
        ),
        const SizedBox(width: 6),
        // QR e-Pass shortcut
        _IconBtn(
          icon: Icons.qr_code_2_rounded,
          onTap: () => context.push('/epass'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// 3-Column Impact Stats (Contributions · Projets · Statut)
// ─────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: AdpColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AdpColors.ink.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: AdpColors.ink.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BlocBuilder<ProjectsCubit, ProjectsState>(
        builder: (context, state) {
          return Row(
            children: [
              BlocBuilder<DonationCubit, DonationState>(
                builder: (context, donationState) {
                  final totalCents = donationState.history.fold<int>(
                      0, (total, donation) => total + donation.amountCents);
                  return _StatCol(
                    value: totalCents == 0 ? '—' : '${(totalCents / 100).toStringAsFixed(0)} €',
                    label: 'Contributions',
                  );
                },
              ),
              _StatCol(value: '${state.items.length}', label: 'Projets actifs'),
              _StatCol(
                value: '2026',
                label: 'Statut actif',
                valueColor: AdpColors.success,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol({
    required this.value,
    required this.label,
    this.valueColor,
  });
  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AdpColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AdpColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 4 Direct Action Buttons (Faire un don · e-Pass · Réseau · Sommet)
// ─────────────────────────────────────────────
class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionCard(
          icon: Icons.favorite_rounded,
          iconColor: AdpColors.terracotta,
          label: 'Faire un don',
          onTap: () => context.push('/donate'),
        ),
        const SizedBox(width: 10),
        _ActionCard(
          icon: Icons.badge_rounded,
          iconColor: AdpColors.ocean,
          label: 'Mon e-Pass',
          onTap: () => context.push('/epass'),
        ),
        const SizedBox(width: 10),
        _ActionCard(
          icon: Icons.people_rounded,
          iconColor: const Color(0xFF0E7490),
          label: 'Réseau',
          onTap: () => context.push('/networking'),
        ),
        const SizedBox(width: 10),
        _ActionCard(
          icon: Icons.public_rounded,
          iconColor: AdpColors.sandGold,
          label: 'Sommet',
          onTap: () => context.push('/summit'),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AdpColors.tealDeep.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdpColors.stroke),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AdpColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Summit 2026 Highlight (Gold left border accent)
// ─────────────────────────────────────────────
class _SummitCard extends StatelessWidget {
  const _SummitCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/summit'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdpColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AdpColors.ink.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: AdpColors.ink.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gold accent bar
            Container(
              width: 3.5,
              height: 48,
              decoration: BoxDecoration(
                color: AdpColors.sandGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AdpColors.ink.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'ÉVÉNEMENT 2026',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AdpColors.ink, letterSpacing: 0.4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Djerba Diaspora Summit',
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AdpColors.ink),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '18-20 Décembre · Houmt Souk · Inscriptions ouvertes',
                    style: TextStyle(fontSize: 12, color: AdpColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AdpColors.ink),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Featured Project Story Card
// ─────────────────────────────────────────────
class _ProjectStoryCard extends StatelessWidget {
  const _ProjectStoryCard({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final percentage = project.target > 0
        ? (project.collected / project.target * 100).clamp(0, 100).toInt()
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: AdpColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdpColors.ink.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: AdpColors.ink.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Solid deep-ink header with category badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(color: AdpColors.ink),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        project.category,
                        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (project.daysLeft != null)
                      Text(
                        'J-${project.daysLeft}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Action terrain en cours',
                  style: TextStyle(
                    color: AdpColors.sandGold.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Body with title, description, progress, CTA
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AdpColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  project.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: AdpColors.muted, height: 1.45),
                ),
                const SizedBox(height: 14),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 4,
                    backgroundColor: AdpColors.ink.withValues(alpha: 0.08),
                    color: AdpColors.terracotta,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdpColors.ink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => context.push('/donate'),
                      icon: const Icon(Icons.favorite_rounded, size: 16),
                      label: const Text(
                        'Contribuer',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
}

// ─────────────────────────────────────────────
// News Card (compact editorial style)
// ─────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.article});
  final News article;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/news'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AdpColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AdpColors.ink.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AdpColors.tealDeep.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(5),
                  ),
                    child: Text(
                      article.category,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AdpColors.tealDeep),
                  ),
                ),
                Text(
                  article.dateFormatted,
                  style: const TextStyle(fontSize: 11, color: AdpColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              article.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AdpColors.ink),
            ),
            const SizedBox(height: 4),
            Text(
              article.excerpt,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AdpColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared utility widgets
// ─────────────────────────────────────────────
class _SectionBar extends StatelessWidget {
  const _SectionBar({
    required this.heading,
    required this.linkText,
    required this.onLinkTap,
  });
  final String heading;
  final String linkText;
  final VoidCallback onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AdpColors.ink,
          ),
        ),
        GestureDetector(
          onTap: onLinkTap,
          child: Text(
            linkText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AdpColors.ocean,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AdpColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AdpColors.ink.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, size: 18, color: AdpColors.ink),
      ),
    );
  }
}

class _QuietState extends StatelessWidget {
  const _QuietState({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdpColors.muted));
}
