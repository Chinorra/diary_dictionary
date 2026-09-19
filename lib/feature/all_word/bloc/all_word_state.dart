import 'package:equatable/equatable.dart';

import '../../../database/database.dart';

enum AllWordStatus { initial, loading, success, error }

class AllWordState extends Equatable {
  final AllWordStatus status;
  final List<Word> words;
  final List<Word> filteredWords;
  final Map<String, List<Word>> groupedWords;
  final String searchQuery;
  final bool searchVisible;
  final String? errorMessage;

  const AllWordState({
    this.status = AllWordStatus.initial,
    this.words = const [],
    this.filteredWords = const [],
    this.groupedWords = const {},
    this.searchQuery = '',
    this.searchVisible = false,
    this.errorMessage,
  });

  bool get isBusy =>
      status == AllWordStatus.initial || status == AllWordStatus.loading;

  bool get hasNoSavedWords => status == AllWordStatus.success && words.isEmpty;

  bool get hasNoSearchResults =>
      status == AllWordStatus.success &&
      words.isNotEmpty &&
      filteredWords.isEmpty;

  AllWordState copyWith({
    AllWordStatus? status,
    List<Word>? words,
    List<Word>? filteredWords,
    Map<String, List<Word>>? groupedWords,
    String? searchQuery,
    bool? searchVisible,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AllWordState(
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
        status,
        words,
        filteredWords,
        groupedWords,
        searchQuery,
        searchVisible,
        errorMessage,
      ];
}
