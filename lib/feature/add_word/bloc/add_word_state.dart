import 'package:equatable/equatable.dart';

import '../models/word_category.dart';

enum AddWordStatus { idle, translating, translated, saving, saved, error }

class AddWordState extends Equatable {
  final String word;
  final List<String> suggestions;
  final bool suggestionsVisible;
  final String category;
  final String definition;
  final String example;
  final String partOfSpeech;
  final String? imagePath;
  final AddWordStatus status;
  final String? errorMessage;
  final String? validationError;

  const AddWordState({
    this.word = '',
    this.suggestions = const [],
    this.suggestionsVisible = false,
    this.category = kDefaultWordCategory,
    this.definition = '',
    this.example = '',
    this.partOfSpeech = '',
    this.imagePath,
    this.status = AddWordStatus.idle,
    this.errorMessage,
    this.validationError,
  });

  bool get isTranslating => status == AddWordStatus.translating;
  bool get isSaving => status == AddWordStatus.saving;

  AddWordState copyWith({
    String? word,
    List<String>? suggestions,
    bool? suggestionsVisible,
    String? category,
    String? definition,
    String? example,
    String? partOfSpeech,
    String? imagePath,
    bool clearImage = false,
    AddWordStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? validationError,
    bool clearValidationError = false,
  }) {
    return AddWordState(
      word: word ?? this.word,
      suggestions: suggestions ?? this.suggestions,
      suggestionsVisible: suggestionsVisible ?? this.suggestionsVisible,
      category: category ?? this.category,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      imagePath: clearImage ? null : imagePath ?? this.imagePath,
      status: status ?? this.status,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      validationError:
          clearValidationError ? null : validationError ?? this.validationError,
    );
  }

  @override
  List<Object?> get props => [
        word,
        suggestions,
        suggestionsVisible,
        category,
        definition,
        example,
        partOfSpeech,
        imagePath,
        status,
        errorMessage,
        validationError,
      ];
}
