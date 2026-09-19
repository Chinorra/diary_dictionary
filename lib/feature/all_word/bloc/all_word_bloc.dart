import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/all_word_repository.dart';
import '../../common/word_grouping.dart';
import 'all_word_event.dart';
import 'all_word_state.dart';

class AllWordBloc extends Bloc<AllWordEvent, AllWordState> {
  AllWordBloc(this._repository) : super(const AllWordState()) {
    on<AllWordsRequested>(_onWordsRequested);
    on<SearchToggled>(_onSearchToggled);
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  final AllWordRepository _repository;

  Future<void> _onWordsRequested(
    AllWordsRequested event,
    Emitter<AllWordState> emit,
  ) async {
    emit(state.copyWith(
      status: AllWordStatus.loading,
      clearErrorMessage: true,
    ));

    try {
      final words = await _repository.getAllWords();
      emit(_applied(
        state.copyWith(status: AllWordStatus.success, words: words),
        state.searchQuery,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AllWordStatus.error,
        errorMessage: 'Unable to load your words.',
      ));
    }
  }

  void _onSearchToggled(
    SearchToggled event,
    Emitter<AllWordState> emit,
  ) {
    final visible = !state.searchVisible;
    emit(_applied(
      state.copyWith(searchVisible: visible),
      visible ? state.searchQuery : '',
    ));
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<AllWordState> emit,
  ) {
    emit(_applied(state, event.query));
  }

  AllWordState _applied(AllWordState source, String query) {
    final filtered = sortWords(filterWords(source.words, query));
    return source.copyWith(
      searchQuery: query,
      filteredWords: filtered,
      groupedWords: groupWords(filtered),
    );
  }
}
