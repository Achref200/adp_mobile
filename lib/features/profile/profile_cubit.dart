import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ProfileActionStatus { idle, running, success, failure }

class ProfileActionState extends Equatable {
  const ProfileActionState(
      {this.status = ProfileActionStatus.idle,
      this.summary = const <String, int>{},
      this.generatedAt,
      this.message});
  final ProfileActionStatus status;
  final Map<String, int> summary;
  final DateTime? generatedAt;
  final String? message;
  @override
  List<Object?> get props => [status, summary, generatedAt, message];
  ProfileActionState copyWith(
          {ProfileActionStatus? status,
          Map<String, int>? summary,
          DateTime? generatedAt,
          String? message}) =>
      ProfileActionState(
          status: status ?? this.status,
          summary: summary ?? this.summary,
          generatedAt: generatedAt ?? this.generatedAt,
          message: message ?? this.message);
}

/// Owns the RGPD actions exposed from the profile screen:
/// data export (art. 20) and erasure request (art. 17).
class ProfileCubit extends Cubit<ProfileActionState> {
  ProfileCubit(this._repository) : super(const ProfileActionState());
  final PrivacyRepository _repository;

  Future<void> exportData() async {
    emit(state.copyWith(status: ProfileActionStatus.running));
    try {
      final data = await _repository.exportData();
      final summary = <String, int>{
        'adhésions': (data['memberships'] as List?)?.length ?? 0,
        'dons': (data['donations'] as List?)?.length ?? 0,
        'consentements': (data['consents'] as List?)?.length ?? 0,
        'notifications': (data['notifications'] as List?)?.length ?? 0,
      };
      emit(ProfileActionState(
          status: ProfileActionStatus.success,
          summary: summary,
          generatedAt: DateTime.now()));
    } catch (_) {
      emit(state.copyWith(
          status: ProfileActionStatus.failure,
          message: "L'export de vos données est momentanément indisponible."));
    }
  }

  Future<void> requestErasure() async {
    emit(state.copyWith(status: ProfileActionStatus.running));
    try {
      await _repository.requestErasure();
      emit(state.copyWith(
          status: ProfileActionStatus.success,
          message:
              'Votre demande de suppression a été enregistrée. Le bureau ADP la traitera sous 30 jours.'));
    } catch (_) {
      emit(state.copyWith(
          status: ProfileActionStatus.failure,
          message:
              "Votre demande n'a pas pu être enregistrée. Réessayez plus tard."));
    }
  }

  void dismiss() => emit(const ProfileActionState());
}
