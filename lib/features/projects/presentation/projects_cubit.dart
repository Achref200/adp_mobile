import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ProjectsStatus { initial, loading, ready, empty, failure }

class ProjectsState extends Equatable {
  const ProjectsState(
      {this.status = ProjectsStatus.initial,
      this.items = const [],
      this.message});
  final ProjectsStatus status;
  final List<Project> items;
  final String? message;
  @override
  List<Object?> get props => [status, items, message];
}

class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit(this._repository) : super(const ProjectsState());
  final ProjectRepository _repository;
  Future<void> load() async {
    emit(const ProjectsState(status: ProjectsStatus.loading));
    try {
      final items = await _repository.list();
      emit(ProjectsState(
          status: items.isEmpty ? ProjectsStatus.empty : ProjectsStatus.ready,
          items: items));
    } catch (_) {
      emit(const ProjectsState(
          status: ProjectsStatus.failure,
          message: 'Les projets sont indisponibles.'));
    }
  }
}
