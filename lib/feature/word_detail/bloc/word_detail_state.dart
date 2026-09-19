import 'package:equatable/equatable.dart';

import '../../../database/database.dart';

/// The fields of a saved word the user may edit on the detail screen.
enum WordDetailField { word, partOfSpeech, category, definition, example }

enum WordDetailStatus { idle, saving, saved, error }

class WordDetailState extends Equatable {
  /// The word as it is stored; the draft values are compared against it to
  /// know whether anything still needs saving.
  final Word saved;
  final String word;
  final String partOfSpeech;
  final String category;
  final String definition;
  final String example;

  /// Fields the user unlocked with the edit icon. Everything else is
  /// read-only.
  final Set<WordDetailField> editingFields;
  final WordDetailStatus status;
  final String? errorMessage;
  final String? validationError;

  const WordDetailState({
    required this.saved,
    required this.word,
    required this.partOfSpeech,
    required this.category,
    required this.definition,
    required this.example,
    this.editingFields = const {},
    this.status = WordDetailStatus.idle,
    this.errorMessage,
    this.validationError,
  });

  /// Opens the screen on the stored values, with every field locked.
  factory WordDetailState.fromWord(Word word) => WordDetailState(
        saved: word,
        word: word.word,
        partOfSpeech: word.partOfSpeech,
        category: word.category,
        definition: word.definition,
        example: word.example,
      );

  bool get isSaving => status == WordDetailStatus.saving;

  bool isEditing(WordDetailField field) => editingFields.contains(field);

  bool get hasUnsavedChanges =>
      word != saved.word ||
      partOfSpeech != saved.partOfSpeech ||
      category != saved.category ||
      definition != saved.definition ||
      example != saved.example;

  String valueOf(WordDetailField field) {
    switch (field) {
      case WordDetailField.word:
        return word;
      case WordDetailField.partOfSpeech:
        return partOfSpeech;
      case WordDetailField.category:
        return category;
      case WordDetailField.definition:
        return definition;
      case WordDetailField.example:
        return example;
    }
  }

  WordDetailState withValue(WordDetailField field, String value) {
    switch (field) {
      case WordDetailField.word:
        return copyWith(word: value);
      case WordDetailField.partOfSpeech:
        return copyWith(partOfSpeech: value);
      case WordDetailField.category:
        return copyWith(category: value);
      case WordDetailField.definition:
        return copyWith(definition: value);
      case WordDetailField.example:
        return copyWith(example: value);
    }
  }

  WordDetailState copyWith({
    Word? saved,
    String? word,
    String? partOfSpeech,
    String? category,
    String? definition,
    String? example,
    Set<WordDetailField>? editingFields,
    WordDetailStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? validationError,
    bool clearValidationError = false,
  }) {
    return WordDetailState(
      saved: saved ?? this.saved,
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      category: category ?? this.category,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      editingFields: editingFields ?? this.editingFields,
      status: status ?? this.status,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      validationError:
          clearValidationError ? null : validationError ?? this.validationError,
    );
  }

  @override
  List<Object?> get props => [
        saved,
        word,
        partOfSpeech,
        category,
        definition,
        example,
        editingFields,
        status,
        errorMessage,
        validationError,
      ];
}
