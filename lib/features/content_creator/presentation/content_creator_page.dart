import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/core/widgets/adp_feedback.dart';
import 'package:adp_mobile/core/widgets/adp_haptic.dart';
import 'package:adp_mobile/features/content_creator/presentation/content_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ContentCreatorPage extends StatefulWidget {
  const ContentCreatorPage({super.key});

  @override
  State<ContentCreatorPage> createState() => _ContentCreatorPageState();
}

class _ContentCreatorPageState extends State<ContentCreatorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleField = TextEditingController();
  final _excerptField = TextEditingController();
  final _locationField = TextEditingController();
  final _descriptionField = TextEditingController();
  final _projectTitleField = TextEditingController();
  final _projectSummaryField = TextEditingController();
  final _projectTargetField = TextEditingController();
  final _newsletterTitleField = TextEditingController();
  final _newsletterSummaryField = TextEditingController();
  final _newsletterContentField = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [
      _titleField,
      _excerptField,
      _locationField,
      _descriptionField,
      _projectTitleField,
      _projectSummaryField,
      _projectTargetField,
      _newsletterTitleField,
      _newsletterSummaryField,
      _newsletterContentField,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContentCubit, ContentState>(
      listener: (context, state) {
        if (state.status == AsyncStatus.failure) {
          AdpFeedback.failure(
            context,
            source: 'Contenu',
            message: state.message ?? 'Erreur lors du chargement.',
          );
        }
      },
      builder: (context, state) {
        final canCreateNews =
            state.currentUser?.role == MemberRole.admin ||
                state.currentUser?.role == MemberRole.contentCreator;
        final canCreateEvent =
            state.currentUser?.role == MemberRole.admin ||
                state.currentUser?.role == MemberRole.contentCreator;
        final canCreateProject =
            state.currentUser?.role == MemberRole.admin ||
                state.currentUser?.role == MemberRole.contentCreator;
        final canCreateNewsletter =
            state.currentUser?.role == MemberRole.admin ||
                state.currentUser?.role == MemberRole.contentCreator;

        return Scaffold(
          backgroundColor: AdpColors.canvas,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const AdpStudioBackButton(),
            title: const Text('Contenu & Publications'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AdpColors.tealDeep,
              indicatorWeight: 3,
              labelColor: AdpColors.ink,
              unselectedLabelColor: AdpColors.muted,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(text: 'Actualités'),
                Tab(text: 'Événements'),
                Tab(text: 'Projets'),
                Tab(text: 'Lettres'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Admin status bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                color: AdpColors.tealDeep.withValues(alpha: 0.06),
                child: Row(
                  children: [
                    Icon(
                      state.currentUser?.role == MemberRole.admin
                          ? Icons.admin_panel_settings_rounded
                          : Icons.edit_note_rounded,
                      size: 16,
                      color: AdpColors.tealDeep,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.currentUser?.role.name == 'admin'
                          ? 'Rôle : Administrateur'
                          : 'Rôle : Créateur de contenu',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AdpColors.tealDeep,
                      ),
                    ),
                    const Spacer(),
                    if (state.currentUser != null)
                      Text(
                        'Connecté en tant que ${state.currentUser!.fullName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AdpColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _DraftsList(
                      items: state.data?.where((item) =>
                          item.type == ContentDraftType.news).toList() ??
                          [],
                      emptyMessage:
                          'Aucune actualité publiée ou en cours de rédaction.',
                      onCreateEnabled: canCreateNews,
                      onCreateLabel: 'Rédiger une actualité',
                      onAdd: () => _showNewsEditor(context),
                    ),
                    _DraftsList(
                      items: state.data?.where((item) =>
                          item.type == ContentDraftType.event).toList() ??
                          [],
                      emptyMessage:
                          'Aucun événement publié ou en cours de préparation.',
                      onCreateEnabled: canCreateEvent,
                      onCreateLabel: 'Créer un événement',
                      onAdd: () => _showEventEditor(context),
                    ),
                    _DraftsList(
                      items: state.data?.where((item) =>
                          item.type == ContentDraftType.project).toList() ??
                          [],
                      emptyMessage:
                          'Aucun projet soumis par les createurs de contenu.',
                      onCreateEnabled: canCreateProject,
                      onCreateLabel: 'Proposer un projet',
                      onAdd: () => _showProjectEditor(context),
                    ),
                    _DraftsList(
                      items: state.data?.where((item) =>
                          item.type == ContentDraftType.newsletter).toList() ??
                          [],
                      emptyMessage:
                          'Aucune lettre d\'information publiée.',
                      onCreateEnabled: canCreateNewsletter,
                      onCreateLabel: 'Rédiger une lettre',
                      onAdd: () => _showNewsletterEditor(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNewsEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NewsEditorForm(
        titleController: _titleField,
        excerptController: _excerptField,
        onSubmit: () async {
          if (_formKey.currentState!.validate()) {
            await context.read<ContentCubit>().submitNews(
                  title: _titleField.text.trim(),
                  excerpt: _excerptField.text.trim(),
                );
            if (mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Actualité soumise pour validation.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AdpColors.tealDeep,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEventEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EventEditorForm(
        titleController: _titleField,
        locationController: _locationField,
        descriptionController: _descriptionField,
        onSubmit: () async {
          if (_formKey.currentState!.validate()) {
            await context.read<ContentCubit>().submitEvent(
                  title: _titleField.text.trim(),
                  location: _locationField.text.trim(),
                  startsAt: DateTime.now().add(const Duration(days: 30)),
                  description: _descriptionField.text.trim(),
                );
            if (mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Événement soumis pour validation.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AdpColors.tealDeep,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showProjectEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProjectEditorForm(
        titleController: _projectTitleField,
        summaryController: _projectSummaryField,
        targetController: _projectTargetField,
        onSubmit: () async {
          if (_formKey.currentState!.validate()) {
            await context.read<ContentCubit>().submitProject(
                  title: _projectTitleField.text.trim(),
                  category: 'Patrimoine',
                  summary: _projectSummaryField.text.trim(),
                  coverColor: '#008891',
                  targetCents: int.tryParse(_projectTargetField.text) ??
                      5000000,
                );
            if (mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Projet soumis pour validation.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AdpColors.tealDeep,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showNewsletterEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NewsletterEditorForm(
        titleController: _newsletterTitleField,
        summaryController: _newsletterSummaryField,
        contentController: _newsletterContentField,
        onSubmit: () async {
          if (_formKey.currentState!.validate()) {
            await context.read<ContentCubit>().submitNewsletter(
                  title: _newsletterTitleField.text.trim(),
                  summary: _newsletterSummaryField.text.trim(),
                  content: _newsletterContentField.text.trim(),
                  coverColor: '#008891',
                );
            if (mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lettre d\'information soumise.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AdpColors.tealDeep,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class _DraftsList extends StatelessWidget {
  final List<ContentDraftItem> items;
  final String emptyMessage;
  final bool onCreateEnabled;
  final String onCreateLabel;
  final VoidCallback onAdd;

  const _DraftsList({
    required this.items,
    required this.emptyMessage,
    required this.onCreateEnabled,
    required this.onCreateLabel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_note_rounded,
              size: 56,
              color: AdpColors.mutedLight,
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 13,
                color: AdpColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            if (onCreateEnabled) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  AdpHaptic.select();
                  onAdd();
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(onCreateLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdpColors.tealDeep,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ContentCubit>().load();
      },
      color: AdpColors.tealDeep,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length + (onCreateEnabled ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(onCreateLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdpColors.tealDeep,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            );
          }
          final item = items[index];
          return _DraftTile(item: item);
        },
      ),
    );
  }
}

class _DraftTile extends StatelessWidget {
  final ContentDraftItem item;
  const _DraftTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (item.status) {
      case ContentStatus.draft:
        statusColor = AdpColors.muted;
        statusLabel = 'Brouillon';
        statusIcon = Icons.edit_outlined;
        break;
      case ContentStatus.pendingReview:
        statusColor = AdpColors.terracotta;
        statusLabel = 'En révision';
        statusIcon = Icons.pending_outlined;
        break;
      case ContentStatus.published:
        statusColor = AdpColors.success;
        statusLabel = 'Publié';
        statusIcon = Icons.check_circle_outlined;
        break;
      case ContentStatus.rejected:
        statusColor = AdpColors.terracotta;
        statusLabel = 'Rejeté';
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.status == ContentStatus.published
              ? AdpColors.success.withValues(alpha: 0.2)
              : AdpColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AdpColors.ink,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateFmt.format(item.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AdpColors.muted,
                  ),
                ),
                if (item.authorName != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Par ${item.authorName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AdpColors.muted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: item.status == ContentStatus.pendingReview ||
                item.status == ContentStatus.draft
            ? const Icon(
                Icons.more_vert_rounded,
                color: AdpColors.muted,
              )
            : null,
      ),
    );
  }
}

// ── Editor forms ──

class _BaseEditorForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;

  const _BaseEditorForm({
    required this.formKey,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nouveau contenu',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AdpColors.ink,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AdpColors.ink.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const Divider(color: AdpColors.border, height: 1),
              // Form body
              Flexible(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Titre',
                            hintText: 'Titre du contenu...',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Le titre est requis'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Description courte...',
                          ),
                          maxLines: 3,
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'La description est requise'
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdpColors.tealDeep,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Publier',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsEditorForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController excerptController;
  final VoidCallback onSubmit;

  const _NewsEditorForm({
    required this.titleController,
    required this.excerptController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: const Text(
                      'Nouvelle actualité',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AdpColors.ink,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AdpColors.ink.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const Divider(color: AdpColors.border, height: 1),
              Flexible(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Titre de l\'actualité',
                            hintText: 'Ex: Les Olympiades de Djerba 2026',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Le titre est requis'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: excerptController,
                          decoration: const InputDecoration(
                            labelText: 'Extrait / chapeau',
                            hintText: 'Une courte introduction...',
                          ),
                          maxLines: 3,
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'L\'extrait est requis'
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      onSubmit();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdpColors.tealDeep,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Soumettre pour validation',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventEditorForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController locationController;
  final TextEditingController descriptionController;
  final VoidCallback onSubmit;

  const _EventEditorForm({
    required this.titleController,
    required this.locationController,
    required this.descriptionController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          constraints: const BoxConstraints(maxHeight: 450),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: const Text(
                      'Nouvel événement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AdpColors.ink,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AdpColors.ink.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const Divider(color: AdpColors.border, height: 1),
              Flexible(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Titre de l\'événement',
                            hintText: 'Ex: Sommet Diaspora 2026',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Le titre est requis'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            labelText: 'Lieu',
                            hintText: 'Ex: Houmt Souk, Djerba',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Le lieu est requis'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Détails de l\'événement...',
                          ),
                          maxLines: 4,
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'La description est requise'
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      onSubmit();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdpColors.tealDeep,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Soumettre pour validation',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectEditorForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController summaryController;
  final TextEditingController targetController;
  final VoidCallback onSubmit;

  const _ProjectEditorForm({
    required this.titleController,
    required this.summaryController,
    required this.targetController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          constraints: const BoxConstraints(maxHeight: 450),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: const Text(
                      'Nouveau projet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AdpColors.ink,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AdpColors.ink.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const Divider(color: AdpColors.border, height: 1),
              Flexible(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Titre du projet',
                            hintText: 'Ex: Le Jenen — Jardin botanique',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Le titre est requis'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: summaryController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Décrivez le projet...',
                          ),
                          maxLines: 4,
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'La description est requise'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: targetController,
                          decoration: const InputDecoration(
                            labelText: 'Objectif (€)',
                            hintText: 'Ex: 50000',
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: false),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'L\'objectif est requis'
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      onSubmit();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdpColors.tealDeep,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Soumettre pour validation',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsletterEditorForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController summaryController;
  final TextEditingController contentController;
  final VoidCallback onSubmit;

  const _NewsletterEditorForm({
    required this.titleController,
    required this.summaryController,
    required this.contentController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: const Text(
                      'Nouvelle lettre',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AdpColors.ink,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AdpColors.ink.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const Divider(color: AdpColors.border, height: 1),
              Flexible(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Titre de la lettre',
                            hintText: 'Ex: ADP Informe — Octobre 2026',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Le titre est requis'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: summaryController,
                          decoration: const InputDecoration(
                            labelText: 'Résumé',
                            hintText: 'En quelques lignes...',
                          ),
                          maxLines: 2,
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Le résumé est requis'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: contentController,
                          decoration: const InputDecoration(
                            labelText: 'Contenu (HTML accepté)',
                            hintText: 'Écrivez le contenu de la lettre...',
                          ),
                          maxLines: 6,
                          maxLength: 2000,
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Le contenu est requis'
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      onSubmit();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdpColors.tealDeep,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Soumettre',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
