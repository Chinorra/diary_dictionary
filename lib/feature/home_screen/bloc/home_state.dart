import 'package:equatable/equatable.dart';

import '../../../database/database.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final DateTime? date;
  final List<Word> words;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.date,
    this.words = const [],
    this.errorMessage,
  });

  bool get isBusy =>
      status == HomeStatus.initial || status == HomeStatus.loading;

  bool get hasNoWords => status == HomeStatus.success && words.isEmpty;

  HomeState copyWith({
    HomeStatus? status,
    DateTime? date,
    List<Word>? words,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      date: date ?? this.date,
      words: words ?? this.words,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, date, words, errorMessage];
}
