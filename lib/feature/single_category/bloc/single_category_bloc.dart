import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/word_grouping.dart';
import '../repository/single_category_repository.dart';
import 'single_category_event.dart';
import 'single_category_state.dart';

class SingleCategoryBloc
    extends Bloc<SingleCategoryEvent, SingleCategoryState> {
  SingleCategoryBloc(this._repository, {required String category})
      : super(SingleCategoryState(category: category)) {
    on<CategoryWordsRequested>(_onWordsRequested);
    on<CategorySearchToggled>(_onSearchToggled);
    on<CategorySearchQueryChanged>(_onSearchQueryChanged);
  }

  final SingleCategoryRepository _repository;

  Future<void> _onWordsRequested(
    CategoryWordsRequested event,
    Emitter<SingleCategoryState> emit,
  ) async {
    emit(state.copyWith(
      status: SingleCategoryStatus.loading,
      clearErrorMessage: true,
    ));

    try {
      final words = await _repository.getWordsByCategory(state.category);
      emit(_applied(
        state.copyWith(status: SingleCategoryStatus.success, words: words),
        state.searchQuery,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: SingleCategoryStatus.error,
        errorMessage: 'Unable to load words in this category.',
      ));
    }
  }

  void _onSearchToggled(
    CategorySearchToggled event,
    Emitter<SingleCategoryState> emit,
  ) {
    final visible = !state.searchVisible;
    emit(_applied(
      state.copyWith(searchVisible: visible),
      visible ? state.searchQuery : '',
    ));
  }

  void _onSearchQueryChanged(
    CategorySearchQueryChanged event,
    Emitter<SingleCategoryState> emit,
  ) {
    emit(_applied(state, event.query));
  }

  SingleCategoryState _applied(SingleCategoryState source, String query) {
    final filtered = sortWords(filterWords(source.words, query));
    return source.copyWith(
      searchQuery: query,
      filteredWords: filtered,
      groupedWords: groupWords(filtered),
    );
  }
}
