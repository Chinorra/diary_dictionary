import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../database/database.dart';
import '../repository/word_detail_repository.dart';
import 'word_detail_event.dart';
import 'word_detail_state.dart';

class WordDetailBloc extends Bloc<WordDetailEvent, WordDetailState> {
  WordDetailBloc(this._repository, Word word)
      : super(WordDetailState.fromWord(word)) {
    on<FieldEditToggled>(_onFieldEditToggled);
    on<FieldChanged>(_onFieldChanged);
    on<EditsDiscarded>(_onEditsDiscarded);
    on<WordSaveRequested>(_onSaveRequested);
  }

  final WordDetailRepository _repository;

  void _onFieldEditToggled(
    FieldEditToggled event,
    Emitter<WordDetailState> emit,
  ) {
    final editing = Set<WordDetailField>.of(state.editingFields);
    if (!editing.remove(event.field)) {
      editing.add(event.field);
    }
    emit(state.copyWith(
      editingFields: editing,
      status: WordDetailStatus.idle,
      clearValidationError: true,
      clearErrorMessage: true,
    ));
  }

  void _onFieldChanged(FieldChanged event, Emitter<WordDetailState> emit) {
    // A locked field cannot be edited, so ignore stray changes for one.
    if (!state.isEditing(event.field)) return;
    emit(state.withValue(event.field, event.value).copyWith(
          status: WordDetailStatus.idle,
          clearValidationError: true,
        ));
  }

  void _onEditsDiscarded(EditsDiscarded event, Emitter<WordDetailState> emit) {
    emit(WordDetailState.fromWord(state.saved));
  }

  Future<void> _onSaveRequested(
    WordSaveRequested event,
    Emitter<WordDetailState> emit,
  ) async {
    if (state.isSaving) return;

    final word = state.word.trim();
    final definition = state.definition.trim();

    if (word.isEmpty) {
      emit(state.copyWith(validationError: 'The word cannot be empty.'));
      return;
    }
    if (definition.isEmpty) {
      emit(state.copyWith(validationError: 'The definition cannot be empty.'));
      return;
    }

    emit(state.copyWith(
      status: WordDetailStatus.saving,
      clearErrorMessage: true,
      clearValidationError: true,
    ));

    try {
      final updated = await _repository.updateWord(
        id: state.saved.id,
        word: word,
        definition: definition,
        example: state.example.trim(),
        partOfSpeech: state.partOfSpeech.trim(),
        category: state.category,
      );

      if (updated == null) {
        emit(state.copyWith(
          status: WordDetailStatus.error,
          errorMessage: 'This word is no longer in your diary.',
        ));
        return;
      }

      // Re-read the stored row so the screen shows what was actually saved,
      // with every field locked again.
      emit(WordDetailState.fromWord(updated)
          .copyWith(status: WordDetailStatus.saved));
    } catch (_) {
      emit(state.copyWith(
        status: WordDetailStatus.error,
        errorMessage: 'Unable to save your changes.',
      ));
    }
  }
}
