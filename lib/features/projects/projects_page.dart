import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/widgets/app_states.dart';
import 'package:adp_mobile/features/projects/presentation/projects_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  String _selectedCategory = 'Tous';
  final _categories = const ['Tous', 'Patrimoine', 'Écologie', 'Éducation', 'Économie'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdpColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Projets Citoyens'),
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
                tooltip: 'Faire un don',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.favorite_rounded, color: AdpColors.terracotta, size: 18),
                onPressed: () => context.push('/donate'),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProjectsCubit, ProjectsState>(
        builder: (context, state) {
          final allProjects = state.items;
          final filteredProjects = _selectedCategory == 'Tous'
              ? allProjects
              : allProjects
                  .where((p) =>
                      p.category.toLowerCase() ==
                      _selectedCategory.toLowerCase())
                  .toList();

          return AdpStateView<List<Project>>(
            isLoading: state.status == ProjectsStatus.loading,
            hasError: state.status == ProjectsStatus.failure,
            isEmpty: state.status != ProjectsStatus.loading && filteredProjects.isEmpty,
            data: filteredProjects,
            errorMessage: state.message ?? 'Veuillez réessayer ultérieurement.',
            onRetry: context.read<ProjectsCubit>().load,
            skeletonType: AdpSkeletonType.projectCard,
            emptyTitle: 'Aucun projet dans cette thématique',
            emptyMessage: 'De nouveaux projets pour « $_selectedCategory » seront présentés prochainement par le comité.',
            emptyIcon: Icons.handyman_outlined,
            contentBuilder: (context, projects) => RefreshIndicator(
              onRefresh: context.read<ProjectsCubit>().load,
              color: AdpColors.sandGold,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              children: [
                // Category Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedCategory = cat);
                          },
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AdpColors.ink,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                          backgroundColor: Colors.white,
                          selectedColor: AdpColors.navy,
                          elevation: isSelected ? 2 : 0,
                          pressElevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AdpColors.navy : AdpColors.border,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${filteredProjects.length} initiatives en cours de soutien',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AdpColors.muted,
                  ),
                ),
                const SizedBox(height: 12),
                if (filteredProjects.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 48, color: AdpColors.muted),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun projet pour le moment dans la catégorie $_selectedCategory',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AdpColors.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredProjects.map((project) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _StoryProjectCard(project: project),
                      )),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}

class _StoryProjectCard extends StatelessWidget {
  const _StoryProjectCard({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);
    final raised = project.raisedCents / 100;
    final target = project.targetCents / 100;
    final pct = (project.progress * 100).clamp(0, 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdpColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0E2129), Color(0xFF173744)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        project.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Djerba Project · 2026',
                      style: TextStyle(
                        color: AdpColors.sandGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (project.daysLeft != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'J-${project.daysLeft}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AdpColors.ink,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  project.summary,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AdpColors.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: project.progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(AdpColors.ocean),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFmt.format(raised),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AdpColors.ink,
                      ),
                    ),
                    Text(
                      '$pct% de ${currencyFmt.format(target)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AdpColors.ocean,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (project.donorsCount != null)
                      Row(
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 16, color: AdpColors.muted),
                          const SizedBox(width: 5),
                          Text(
                            '${project.donorsCount} donateurs',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AdpColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdpColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.push(
                        Uri(path: '/donate', queryParameters: {
                          'projectId': project.id,
                          'projectName': project.title,
                        }).toString(),
                      ),
                      child: const Text(
                        'Soutenir',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
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
