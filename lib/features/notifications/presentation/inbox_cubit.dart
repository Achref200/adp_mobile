import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InboxState extends AsyncState<List<AppNotification>> {
  const InboxState(
      {super.status, super.data, super.message, this.unreadCount = 0});
  final int unreadCount;
  @override
  List<Object?> get props => [...super.props, unreadCount];
  InboxState copyWith(
          {AsyncStatus? status,
          List<AppNotification>? data,
          String? message,
          int? unreadCount}) =>
      InboxState(
          status: status ?? this.status,
          data: data ?? this.data,
          message: message,
          unreadCount: unreadCount ?? this.unreadCount);
}

class InboxCubit extends Cubit<InboxState> {
  InboxCubit(this._repository) : super(const InboxState());
  final NotificationRepository _repository;

  static int _countUnread(List<AppNotification> messages) =>
      messages.where((m) => !m.read).length;

  Future<void> load() async {
    emit(state.copyWith(status: AsyncStatus.loading));
    try {
      final messages = await _repository.listNotifications();
      emit(InboxState(
        status: messages.isEmpty ? AsyncStatus.empty : AsyncStatus.success,
        data: messages,
        unreadCount: _countUnread(messages),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AsyncStatus.failure,
        message: 'Les notifications sont temporairement indisponibles.',
      ));
    }
  }

  Future<void> markRead(AppNotification notification) async {
    if (notification.read) return;
    // Optimistic: flip locally first so the badge updates instantly.
    final updated = state.data!
        .map((m) => m.id == notification.id ? _asRead(m) : m)
        .toList(growable: false);
    emit(state.copyWith(data: updated, unreadCount: _countUnread(updated)));
    try {
      await _repository.markRead(notification.id);
    } catch (_) {
      await load(); // revert to server truth on failure
    }
  }

  Future<void> markAllRead() async {
    if (state.unreadCount == 0) return;
    final updated =
        state.data!.map(_asRead).toList(growable: false);
    emit(state.copyWith(data: updated, unreadCount: 0));
    try {
      await _repository.markAllRead();
    } catch (_) {
      await load();
    }
  }

  static AppNotification _asRead(AppNotification m) => AppNotification(
      id: m.id, title: m.title, body: m.body, createdAt: m.createdAt, read: true);
}
