import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences extends Equatable {
  const NotificationPreferences(
      {this.news = true,
      this.projects = true,
      this.events = true,
      this.networking = true,
      this.membership = true});
  final bool news, projects, events, networking, membership;
  @override
  List<Object?> get props => [news, projects, events, networking, membership];
  NotificationPreferences copyWith(
          {bool? news,
          bool? projects,
          bool? events,
          bool? networking,
          bool? membership}) =>
      NotificationPreferences(
          news: news ?? this.news,
          projects: projects ?? this.projects,
          events: events ?? this.events,
          networking: networking ?? this.networking,
          membership: membership ?? this.membership);
}

class NotificationCubit extends Cubit<NotificationPreferences> {
  NotificationCubit() : super(const NotificationPreferences());
  Future<void> restore() async {
    final p = await SharedPreferences.getInstance();
    emit(NotificationPreferences(
        news: p.getBool('notify.news') ?? true,
        projects: p.getBool('notify.projects') ?? true,
        events: p.getBool('notify.events') ?? true,
        networking: p.getBool('notify.networking') ?? true,
        membership: p.getBool('notify.membership') ?? true));
  }

  Future<void> update(NotificationPreferences next) async {
    emit(next);
    final p = await SharedPreferences.getInstance();
    await p.setBool('notify.news', next.news);
    await p.setBool('notify.projects', next.projects);
    await p.setBool('notify.events', next.events);
    await p.setBool('notify.networking', next.networking);
    await p.setBool('notify.membership', next.membership);
  }
}
