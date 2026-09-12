import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/dictionary_lookup.dart';
import '../repository/add_word_repository.dart';
import 'add_word_event.dart';
import 'add_word_state.dart';

class AddWordBloc extends Bloc<AddWordEvent, AddWordState> {
  AddWordBloc(this._repository) : super(const AddWordState()) {
    on<WordQueryChanged>(_onQueryChanged);
    on<SuggestionSelected>(_onSuggestionSelected);
    on<SuggestionsDismissed>(_onSuggestionsDismissed);
    on<TranslateRequested>(_onTranslateRequested);
    on<CategoryChanged>(_onCategoryChanged);
    on<DefinitionChanged>(_onDefinitionChanged);
    on<ExampleChanged>(_onExampleChanged);
    on<ImageSelected>(_onImageSelected);
    on<ImageRemoved>(_onImageRemoved);
    on<SaveRequested>(_onSaveRequested);
  }

  final AddWordRepository _repository;
  Timer? _suggestionDebounce;
  int _suggestionRequestId = 0;

  @override
  Future<void> close() {
    _suggestionDebounce?.cancel();
    return super.close();
  }

  Future<void> _onQueryChanged(
    WordQueryChanged event,
    Emitter<AddWordState> emit,
  ) async {
    final query = event.query;
    emit(state.copyWith(
      word: query,
      suggestionsVisible: query.trim().isNotEmpty,
      clearValidationError: true,
    ));

    _suggestionDebounce?.cancel();
    if (query.trim().isEmpty) {
      emit(state.copyWith(suggestions: const [], suggestionsVisible: false));
      return;
    }

    final requestId = ++_suggestionRequestId;
    final completer = Completer<List<String>>();
    _suggestionDebounce = Timer(const Duration(milliseconds: 250), () async {
      try {
        final results = await _repository.fetchSuggestions(query);
        completer.complete(results);
      } catch (_) {
        completer.complete(const []);
      }
    });

    final results = await completer.future;
    if (requestId != _suggestionRequestId || isClosed) return;
    emit(state.copyWith(
      suggestions: results,
      suggestionsVisible: results.isNotEmpty,
    ));
  }

  void _onSuggestionSelected(
    SuggestionSelected event,
    Emitter<AddWordState> emit,
  ) {
    _suggestionRequestId++;
    _suggestionDebounce?.cancel();
    emit(state.copyWith(
      word: event.suggestion,
      suggestions: const [],
      suggestionsVisible: false,
    ));
  }

  void _onSuggestionsDismissed(
    SuggestionsDismissed event,
    Emitter<AddWordState> emit,
  ) {
    emit(state.copyWith(suggestionsVisible: false));
  }

  Future<void> _onTranslateRequested(
    TranslateRequested event,
    Emitter<AddWordState> emit,
  ) async {
    final word = state.word.trim();
    if (word.isEmpty) {
      emit(state.copyWith(
        validationError: 'Please enter a word before translating.',
      ));
      return;
    }
    if (state.isTranslating) return;

    emit(state.copyWith(
      status: AddWordStatus.translating,
      suggestionsVisible: false,
      clearErrorMessage: true,
      clearValidationError: true,
    ));

    try {
      final result = await _repository.translate(word);
      emit(state.copyWith(
        status: AddWordStatus.translated,
        definition: result.definition,
        example: result.example,
        partOfSpeech: result.partOfSpeech,
      ));
    } on DictionaryException catch (e) {
      emit(state.copyWith(
        status: AddWordStatus.error,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AddWordStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  void _onCategoryChanged(
    CategoryChanged event,
    Emitter<AddWordState> emit,
  ) {
    emit(state.copyWith(category: event.category));
  }

  void _onDefinitionChanged(
    DefinitionChanged event,
    Emitter<AddWordState> emit,
  ) {
    emit(state.copyWith(
      definition: event.definition,
      clearValidationError: true,
    ));
  }

  void _onExampleChanged(
    ExampleChanged event,
    Emitter<AddWordState> emit,
  ) {
    emit(state.copyWith(example: event.example));
  }

  void _onImageSelected(
    ImageSelected event,
    Emitter<AddWordState> emit,
  ) {
    if (event.path == null) {
      emit(state.copyWith(clearImage: true));
    } else {
      emit(state.copyWith(imagePath: event.path));
    }
  }

  void _onImageRemoved(
    ImageRemoved event,
    Emitter<AddWordState> emit,
  ) {
    emit(state.copyWith(clearImage: true));
  }

  Future<void> _onSaveRequested(
    SaveRequested event,
    Emitter<AddWordState> emit,
  ) async {
    final word = state.word.trim();
    final definition = state.definition.trim();

    if (word.isEmpty) {
      emit(state.copyWith(validationError: 'Word is required.'));
      return;
    }
    if (definition.isEmpty) {
      emit(state.copyWith(validationError: 'Definition is required.'));
      return;
    }
    if (state.isSaving) return;

    emit(state.copyWith(
      status: AddWordStatus.saving,
      clearErrorMessage: true,
      clearValidationError: true,
    ));

    try {
      await _repository.saveWord(
        word: word,
        definition: definition,
        example: state.example,
        partOfSpeech: state.partOfSpeech,
        category: state.category,
        imagePath: state.imagePath,
      );
      emit(state.copyWith(status: AddWordStatus.saved));
    } catch (_) {
      emit(state.copyWith(
        status: AddWordStatus.error,
        errorMessage: 'Could not save the word. Please try again.',
      ));
    }
  }
}
