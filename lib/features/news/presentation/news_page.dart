import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/core/widgets/app_states.dart';
import 'package:adp_mobile/features/news/presentation/news_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AdpColors.canvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const AdpStudioBackButton(),
          title: const Text('Actualités de l\'île'),
        ),
        body: BlocBuilder<NewsCubit, AsyncState<List<News>>>(
          builder: (context, state) {
            final articles = state.data ?? const <News>[];
            return AdpStateView<List<News>>(
              isLoading: state.isLoading,
              hasError: state.status == AsyncStatus.failure,
              isEmpty: !state.isLoading && articles.isEmpty,
              data: articles,
              errorMessage: state.message ?? 'Veuillez réessayer plus tard.',
              onRetry: context.read<NewsCubit>().load,
              skeletonType: AdpSkeletonType.list,
              emptyTitle: 'Aucun article pour le moment',
              emptyMessage:
                  'Les prochaines actualités et tribunes d\'ADP seront publiées ici.',
              emptyIcon: Icons.newspaper_outlined,
              contentBuilder: (context, newsList) => RefreshIndicator(
                onRefresh: context.read<NewsCubit>().load,
                color: AdpColors.sandGold,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  itemCount: newsList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) =>
                      _ArticleCard(article: newsList[index]),
                ),
              ),
            );
          },
        ),
      );
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});
  final News article;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMMM yyyy', 'fr_FR');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdpColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => _ArticleDetail(article: article)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AdpColors.ocean.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ÉDITORIAL ADP',
                      style: TextStyle(
                        color: AdpColors.ocean,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${dateFmt.format(article.publishedAt)} · 3 min',
                    style: const TextStyle(fontSize: 11, color: AdpColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: AdpColors.ink,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                article.excerpt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, color: AdpColors.muted, height: 1.4),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Par Rédaction ADP',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AdpColors.ink,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 16, color: AdpColors.muted),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Lien de l\'article partagé'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AdpColors.navy,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleDetail extends StatelessWidget {
  const _ArticleDetail({required this.article});
  final News article;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMMM yyyy', 'fr_FR');
    return Scaffold(
      backgroundColor: AdpColors.background,
      appBar: AppBar(
        title: const Text('Actualité', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'Partager',
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Lien copié'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AdpColors.navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AdpColors.ocean.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'COMMUNICATION OFFICIELLE',
              style: TextStyle(color: AdpColors.ocean, fontSize: 10.5, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AdpColors.ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Publié le ${dateFmt.format(article.publishedAt)} · Par Rédaction ADP',
            style: const TextStyle(fontSize: 12, color: AdpColors.muted),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AdpColors.border),
            ),
            child: Text(
              article.excerpt,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AdpColors.ink,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'L\'Association Djerba Project poursuit ses travaux de concertation avec les institutions locales, les porteurs de projets et l\'ensemble des membres de la diaspora à travers le monde.\n\nCet engagement s\'inscrit dans une démarche pérenne de valorisation du patrimoine insulaire, de protection environnementale et de transmission intergénérationnelle.',
            style: TextStyle(fontSize: 13.5, color: AdpColors.ink, height: 1.6),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
