import 'package:flutter_test/flutter_test.dart';
import 'package:my_dictionary/database/database.dart';
import 'package:my_dictionary/feature/word_detail/bloc/word_detail_bloc.dart';
import 'package:my_dictionary/feature/word_detail/bloc/word_detail_event.dart';
import 'package:my_dictionary/feature/word_detail/bloc/word_detail_state.dart';
import 'package:my_dictionary/feature/word_detail/repository/word_detail_repository.dart';

Word _word({
  String word = 'apple',
  String definition = 'A round fruit.',
  String example = 'I ate an apple.',
  String partOfSpeech = 'noun',
  String category = 'Food',
}) =>
    Word(
      id: 7,
      word: word,
      definition: definition,
      example: example,
      partOfSpeech: partOfSpeech,
      category: category,
      createdAt: DateTime(2026, 9, 12, 8, 30),
    );

/// Records the writes the bloc asks for, so the saved values can be checked
/// without a real database.
class _FakeWordDetailRepository implements WordDetailRepository {
  _FakeWordDetailRepository(this.stored, {this.shouldFail = false});

  Word? stored;
  final bool shouldFail;

  final List<Map<String, Object?>> writes = [];

  @override
  Future<Word?> getWord(int id) async => stored;

  @override
  Future<Word?> updateWord({
    required int id,
    required String word,
    required String definition,
    required String example,
    required String partOfSpeech,
    required String category,
  }) async {
    writes.add({
      'id': id,
      'word': word,
      'definition': definition,
      'example': example,
      'partOfSpeech': partOfSpeech,
      'category': category,
    });
    if (shouldFail) throw Exception('database unavailable');
    final current = stored;
    if (current == null) return null;
    stored = current.copyWith(
      word: word,
      definition: definition,
      example: example,
      partOfSpeech: partOfSpeech,
      category: category,
    );
    return stored;
  }
}

void main() {
  group('WordDetailState', () {
    test('opens on the stored values with every field locked', () {
      final state = WordDetailState.fromWord(_word());

      expect(state.word, 'apple');
      expect(state.definition, 'A round fruit.');
      expect(state.example, 'I ate an apple.');
      expect(state.partOfSpeech, 'noun');
      expect(state.category, 'Food');
      expect(state.editingFields, isEmpty);
      expect(state.hasUnsavedChanges, isFalse);
      for (final field in WordDetailField.values) {
        expect(state.isEditing(field), isFalse, reason: '$field');
      }
    });
  });

  group('WordDetailBloc', () {
    late _FakeWordDetailRepository repository;
    late WordDetailBloc bloc;

    setUp(() {
      repository = _FakeWordDetailRepository(_word());
      bloc = WordDetailBloc(repository, _word());
    });

    tearDown(() async {
      await bloc.close();
    });

    test('ignores changes to a field that was never unlocked', () async {
      bloc.add(const FieldChanged(WordDetailField.definition, 'sneaky edit'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.definition, 'A round fruit.');
      expect(bloc.state.hasUnsavedChanges, isFalse);
    });

    test('the edit icon unlocks a single field and then locks it', () async {
      bloc.add(const FieldEditToggled(WordDetailField.definition));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isEditing(WordDetailField.definition), isTrue);
      expect(bloc.state.isEditing(WordDetailField.example), isFalse);

      bloc.add(const FieldEditToggled(WordDetailField.definition));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isEditing(WordDetailField.definition), isFalse);
    });

    test('keeps an edit made while the field was unlocked', () async {
      bloc
        ..add(const FieldEditToggled(WordDetailField.example))
        ..add(const FieldChanged(WordDetailField.example, 'My own sentence.'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.example, 'My own sentence.');
      expect(bloc.state.hasUnsavedChanges, isTrue);
      // Locking the field again must not throw the edit away.
      bloc.add(const FieldEditToggled(WordDetailField.example));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.example, 'My own sentence.');
      expect(bloc.state.hasUnsavedChanges, isTrue);
    });

    test('saves the edited fields and locks everything again', () async {
      bloc
        ..add(const FieldEditToggled(WordDetailField.definition))
        ..add(const FieldChanged(
          WordDetailField.definition,
          '  A crisp orchard fruit.  ',
        ))
        ..add(const FieldEditToggled(WordDetailField.category))
        ..add(const FieldChanged(WordDetailField.category, 'Nature'))
        ..add(const WordSaveRequested());

      final state = await bloc.stream.firstWhere(
        (state) => state.status == WordDetailStatus.saved,
      );

      expect(repository.writes.single, {
        'id': 7,
        'word': 'apple',
        'definition': 'A crisp orchard fruit.',
        'example': 'I ate an apple.',
        'partOfSpeech': 'noun',
        'category': 'Nature',
      });
      expect(state.definition, 'A crisp orchard fruit.');
      expect(state.category, 'Nature');
      expect(state.editingFields, isEmpty);
      expect(state.hasUnsavedChanges, isFalse);
    });

    test('keeps the diary day of the saved word', () async {
      bloc
        ..add(const FieldEditToggled(WordDetailField.word))
        ..add(const FieldChanged(WordDetailField.word, 'apples'))
        ..add(const WordSaveRequested());

      final state = await bloc.stream.firstWhere(
        (state) => state.status == WordDetailStatus.saved,
      );

      expect(state.saved.createdAt, DateTime(2026, 9, 12, 8, 30));
    });

    test('refuses to save an empty word or definition', () async {
      bloc
        ..add(const FieldEditToggled(WordDetailField.word))
        ..add(const FieldChanged(WordDetailField.word, '   '))
        ..add(const WordSaveRequested());

      final state = await bloc.stream.firstWhere(
        (state) => state.validationError != null,
      );

      expect(state.validationError, 'The word cannot be empty.');
      expect(repository.writes, isEmpty);
    });

    test('discarding restores the stored values and locks the fields',
        () async {
      bloc
        ..add(const FieldEditToggled(WordDetailField.definition))
        ..add(const FieldChanged(WordDetailField.definition, 'changed'))
        ..add(const EditsDiscarded());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.definition, 'A round fruit.');
      expect(bloc.state.editingFields, isEmpty);
      expect(bloc.state.hasUnsavedChanges, isFalse);
      expect(repository.writes, isEmpty);
    });

    test('surfaces a readable message when saving fails', () async {
      final failing = WordDetailBloc(
        _FakeWordDetailRepository(_word(), shouldFail: true),
        _word(),
      );

      failing
        ..add(const FieldEditToggled(WordDetailField.definition))
        ..add(const FieldChanged(WordDetailField.definition, 'changed'))
        ..add(const WordSaveRequested());

      final state = await failing.stream.firstWhere(
        (state) => state.status == WordDetailStatus.error,
      );

      expect(state.errorMessage, 'Unable to save your changes.');
      expect(state.errorMessage, isNot(contains('Exception')));
      // The edit is kept so the user can try again.
      expect(state.definition, 'changed');

      await failing.close();
    });
  });
}
