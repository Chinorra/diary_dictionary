import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => const [];
}

/// Loads the words saved on [date], defaulting to today.
class DiaryDayRequested extends HomeEvent {
  final DateTime? date;

  const DiaryDayRequested([this.date]);

  @override
  List<Object?> get props => [date];
}
