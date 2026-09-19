import 'package:equatable/equatable.dart';

import '../../../database/database.dart';

enum SingleCategoryStatus { initial, loading, success, error }

class SingleCategoryState extends Equatable {
  final String category;
  final SingleCategoryStatus status;
  final List<Word> words;
  final List<Word> filteredWords;
  final Map<String, List<Word>> groupedWords;
  final String searchQuery;
  final bool searchVisible;
  final String? errorMessage;

  const SingleCategoryState({
    required this.category,
    this.status = SingleCategoryStatus.initial,
    this.words = const [],
    this.filteredWords = const [],
    this.groupedWords = const {},
    this.searchQuery = '',
    this.searchVisible = false,
    this.errorMessage,
  });

  bool get isBusy =>
      status == SingleCategoryStatus.initial ||
      status == SingleCategoryStatus.loading;

  /// The category itself holds no saved words yet.
  bool get hasNoSavedWords =>
      status == SingleCategoryStatus.success && words.isEmpty;

  /// The category holds words, but none of them match the current search.
  bool get hasNoSearchResults =>
      status == SingleCategoryStatus.success &&
      words.isNotEmpty &&
      filteredWords.isEmpty;

  SingleCategoryState copyWith({
    SingleCategoryStatus? status,
    List<Word>? words,
    List<Word>? filteredWords,
    Map<String, List<Word>>? groupedWords,
    String? searchQuery,
    bool? searchVisible,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SingleCategoryState(
      category: category,
      status: status ?? this.status,
      words: words ?? this.words,
      filteredWords: filteredWords ?? this.filteredWords,
      groupedWords: groupedWords ?? this.groupedWords,
      searchQuery: searchQuery ?? this.searchQuery,
      searchVisible: searchVisible ?? this.searchVisible,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        category,
        status,
        words,
        filteredWords,
        groupedWords,
        searchQuery,
        searchVisible,
        errorMessage,
      ];
}
