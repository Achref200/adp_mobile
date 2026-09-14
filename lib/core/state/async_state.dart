import 'package:equatable/equatable.dart';

enum AsyncStatus { initial, loading, success, empty, failure }

class AsyncState<T> extends Equatable {
  const AsyncState(
      {this.status = AsyncStatus.initial, this.data, this.message});
  final AsyncStatus status;
  final T? data;
  final String? message;
  bool get isLoading => status == AsyncStatus.loading;
  @override
  List<Object?> get props => [status, data, message];
}
