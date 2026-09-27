import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/auth/presentation/auth_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/data/api_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentState extends AsyncState<List<ContentDraftItem>> {
  const ContentState({
    super.status,
    super.data,
    super.message,
    this.selectedTab = 0,
    this.currentUser,
  });
  final int selectedTab;
  final User? currentUser;

  @override
  List<Object?> get props => [...super.props, selectedTab, currentUser];
}

class ContentDraftItem {
  const ContentDraftItem({
    required this.type,
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    this.authorName,
    this.category,
  });
  final ContentDraftType type;
  final String id;
  final String title;
  final ContentStatus status;
  final DateTime createdAt;
  final String? authorName;
  final String? category;
}

enum ContentDraftType { news, event, project, newsletter }

class ContentCubit extends Cubit<ContentState> {
  ContentCubit(this._repository) : super(const ContentState());
  final ApiAdpRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AsyncStatus.loading));
    try {
      final currentUser = context.read<AuthCubit>().state.session?.user;
      final results = await Future.wait([
        _repository.listNewsDrafts(),
        _repository.listEventDrafts(),
        _repository.listProjectDrafts(),
        _repository.listNewsletterDrafts(),
      ]);
      final items = <ContentDraftItem>[];
      for (final news in results[0] as List<News>) {
        items.add(ContentDraftItem(
          type: ContentDraftType.news,
          id: news.id,
          title: news.title,
          status: news.isPreview ? ContentStatus.pendingReview : ContentStatus.published,
          createdAt: news.publishedAt,
          authorName: news.authorName,
        ));
      }
      for (final event in results[1] as List<Event>) {
        items.add(ContentDraftItem(
          type: ContentDraftType.event,
          id: event.id,
          title: event.title,
          status: event.isPreview ? ContentStatus.pendingReview : ContentStatus.published,
          createdAt: event.startsAt,
          authorName: event.authorName,
        ));
      }
      for (final project in results[2] as List<ProjectDraft>) {
        items.add(ContentDraftItem(
          type: ContentDraftType.project,
          id: project.id,
          title: project.title,
          status: project.status,
          createdAt: project.createdAt,
          authorName: project.authorName,
          category: project.category,
        ));
      }
      for (final newsletter in results[3] as List<Newsletter>) {
        items.add(ContentDraftItem(
          type: ContentDraftType.newsletter,
          id: newsletter.id,
          title: newsletter.title,
          status: newsletter.status,
          createdAt: newsletter.createdAt,
          authorName: newsletter.authorName,
        ));
      }
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(ContentState(
        status: AsyncStatus.success,
        data: items,
        currentUser: currentUser,
      ));
    } catch (e) {
      emit(ContentState(
        status: AsyncStatus.failure,
        message: 'Impossible de charger les contenus.',
      ));
    }
  }

  void selectTab(int index) => emit(state.copyWith(selectedTab: index));

  Future<void> submitNews({required String title, required String excerpt}) async {
    try {
      final user = context.read<AuthCubit>().state.session?.user;
      await _repository.submitNewsDraft(News(
        id: 'draft',
        title: title,
        excerpt: excerpt,
        publishedAt: DateTime.now(),
        authorId: user?.id,
        authorName: user?.fullName,
        isPreview: true,
      ));
      await load();
    } catch (_) {
      emit(state.copyWith(
        status: AsyncStatus.failure,
        message: 'Erreur lors de la soumission de l\'actualité.',
      ));
    }
  }

  Future<void> submitEvent({
    required String title,
    required String location,
    required DateTime startsAt,
    required String description,
  }) async {
    try {
      final user = context.read<AuthCubit>().state.session?.user;
      await _repository.submitEventDraft(Event(
        id: 'draft',
        title: title,
        location: location,
        startsAt: startsAt,
        description: description,
        authorId: user?.id,
        authorName: user?.fullName,
        isPreview: true,
      ));
      await load();
    } catch (_) {
      emit(state.copyWith(
        status: AsyncStatus.failure,
        message: 'Erreur lors de la soumission de l\'événement.',
      ));
    }
  }

  Future<void> submitProject({
    required String title,
    required String category,
    required String summary,
    required String coverColor,
    int? targetCents,
  }) async {
    try {
      final user = context.read<AuthCubit>().state.session?.user;
      await _repository.submitProjectDraft(ProjectDraft(
        id: 'draft',
        title: title,
        category: category,
        summary: summary,
        coverColor: coverColor,
        status: ContentStatus.draft,
        createdAt: DateTime.now(),
        targetCents: targetCents,
        authorId: user?.id,
        authorName: user?.fullName,
      ));
      await load();
    } catch (_) {
      emit(state.copyWith(
        status: AsyncStatus.failure,
        message: 'Erreur lors de la soumission du projet.',
      ));
    }
  }

  Future<void> submitNewsletter({
    required String title,
    required String summary,
    required String content,
    required String coverColor,
  }) async {
    try {
      final user = context.read<AuthCubit>().state.session?.user;
      await _repository.submitNewsletterDraft(Newsletter(
        id: 'draft',
        title: title,
        summary: summary,
        content: content,
        coverColor: coverColor,
        status: ContentStatus.draft,
        createdAt: DateTime.now(),
        authorId: user?.id,
        authorName: user?.fullName,
      ));
      await load();
    } catch (_) {
      emit(state.copyWith(
        status: AsyncStatus.failure,
        message: 'Erreur lors de la soumission de la lettre.',
      ));
    }
  }
}
