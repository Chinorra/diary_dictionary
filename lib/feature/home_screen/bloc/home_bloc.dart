import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const HomeState()) {
    on<DiaryDayRequested>(_onDiaryDayRequested);
  }

  final HomeRepository _repository;

  Future<void> _onDiaryDayRequested(
    DiaryDayRequested event,
    Emitter<HomeState> emit,
  ) async {
    final date = event.date ?? DateTime.now();

    emit(state.copyWith(
      status: HomeStatus.loading,
      date: date,
      clearErrorMessage: true,
    ));

    try {
      final words = await _repository.getWordsByDate(date);
      emit(state.copyWith(status: HomeStatus.success, words: words));
    } catch (_) {
      emit(state.copyWith(
        status: HomeStatus.error,
        words: const [],
        errorMessage: 'Unable to load your words for this day.',
      ));
    }
  }
}
