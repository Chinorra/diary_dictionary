import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dictionary/database/database.dart';
import 'package:my_dictionary/feature/add_word/models/word_category.dart';
import 'package:my_dictionary/feature/category/models/category_summary.dart';
import 'package:my_dictionary/feature/category/repository/category_repository.dart';
import 'package:my_dictionary/feature/single_category/bloc/single_category_bloc.dart';
import 'package:my_dictionary/feature/single_category/bloc/single_category_event.dart';
import 'package:my_dictionary/feature/single_category/bloc/single_category_state.dart';
import 'package:my_dictionary/feature/single_category/repository/single_category_repository.dart';

Word _word(String value, {String category = 'Animal'}) => Word(
      id: value.hashCode,
      word: value,
      definition: 'definition of $value',
      example: '',
      partOfSpeech: 'noun',
      category: category,
      createdAt: DateTime(2026, 9, 13),
    );

/// Stands in for the database-backed repository so the bloc can be exercised
/// without a real database.
class _FakeSingleCategoryRepository implements SingleCategoryRepository {
  _FakeSingleCategoryRepository(this.wordsByCategory, {this.shouldFail = false});

  final Map<String, List<Word>> wordsByCategory;
  final bool shouldFail;

  final List<String> requestedCategories = [];

  @override
  Future<List<Word>> getWordsByCategory(String category) async {
    requestedCategories.add(category);
    if (shouldFail) throw Exception('database unavailable');
    return wordsByCategory[category] ?? const [];
  }
}

void main() {
  group('buildCategorySummaries', () {
    test('keeps every known category, including empty ones', () {
      final summaries = buildCategorySummaries({'Food': 3});

      expect(
        summaries.map((s) => s.name),
        containsAll(kWordCategories),
      );
      expect(
        summaries.firstWhere((s) => s.name == 'Food').wordCount,
        3,
      );

      final technology = summaries.firstWhere((s) => s.name == 'Technology');
      expect(technology.wordCount, 0);
      expect(technology.isEmpty, isTrue);
    });

    test('preserves the canonical category order', () {
      final summaries = buildCategorySummaries({'Travel': 1});

      expect(
        summaries.take(kWordCategories.length).map((s) => s.name),
        kWordCategories,
      );
    });

    test('appends categories that only exist in saved data', () {
      final summaries = buildCategorySummaries({'Animal': 2, 'Sports': 1});

      expect(summaries.length, kWordCategories.length + 2);
      expect(
        summaries.skip(kWordCategories.length).map((s) => s.name),
        ['Animal', 'Sports'],
      );
      expect(
        summaries.firstWhere((s) => s.name == 'Animal').wordCount,
        2,
      );
    });
  });

  group('user-created categories', () {
    test('are listed first, newest first, with their word counts', () {
      final summaries = buildCategorySummaries(
        {'Hobby': 2, 'Food': 1},
        userCategories: ['New Category 2', 'Hobby'],
      );

      expect(
        summaries.take(2).map((s) => s.name),
        ['New Category 2', 'Hobby'],
      );
      expect(summaries.first.wordCount, 0);
      expect(summaries.first.isEmpty, isTrue);
      expect(summaries[1].wordCount, 2);
      // The canonical list still follows, unchanged.
      expect(
        summaries.skip(2).take(kWordCategories.length).map((s) => s.name),
        kWordCategories,
      );
    });

    test('are not duplicated by the words saved in them', () {
      final summaries = buildCategorySummaries(
        {'Hobby': 1},
        userCategories: ['Hobby'],
      );

      expect(summaries.where((s) => s.name == 'Hobby'), hasLength(1));
      expect(summaries.length, kWordCategories.length + 1);
    });

    test('never shadow a canonical category', () {
      final summaries = buildCategorySummaries(
        const {},
        userCategories: ['Food'],
      );

      expect(summaries.where((s) => s.name == 'Food'), hasLength(1));
      expect(summaries.map((s) => s.name), kWordCategories);
    });
  });

  group('category names', () {
    test('sanitizing trims and collapses the spaces the user typed', () {
      expect(sanitizeCategoryName('  My   Words '), 'My Words');
      expect(sanitizeCategoryName('   '), '');
    });

    test('duplicates are spotted whatever the case or spacing', () {
      final existing = ['Food', 'My Words'];

      expect(isDuplicateCategoryName(existing, 'food'), isTrue);
      expect(isDuplicateCategoryName(existing, '  MY   WORDS  '), isTrue);
      expect(isDuplicateCategoryName(existing, 'Hobby'), isFalse);
    });
  });

  group('CategoryRepository.createCategory', () {
    late AppDatabase database;
    late CategoryRepository repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = CategoryRepository(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('stores the typed name and lists it first', () async {
      final categories = await repository.createCategory('  My   Words ');

      expect(categories.first.name, 'My Words');
      expect(categories.first.wordCount, 0);
      expect(await database.getUserCategoryNames(), ['My Words']);
    });

    test('rejects a name that is already taken, ignoring case', () async {
      await repository.createCategory('Hobby');

      expect(
        () => repository.createCategory('hobby'),
        throwsA(isA<CategoryNameException>().having(
          (e) => e.message,
          'message',
          'That category already exists.',
        )),
      );
      expect(await database.getUserCategoryNames(), ['Hobby']);
    });

    test('rejects a canonical category name', () async {
      expect(
        () => repository.createCategory('Food'),
        throwsA(isA<CategoryNameException>()),
      );
      expect(await database.getUserCategoryNames(), isEmpty);
    });

    test('rejects a blank name', () async {
      expect(
        () => repository.createCategory('   '),
        throwsA(isA<CategoryNameException>().having(
          (e) => e.message,
          'message',
          'Please enter a category name.',
        )),
      );
      expect(await database.getUserCategoryNames(), isEmpty);
    });
  });

  group('SingleCategoryBloc', () {
    test('loads, sorts and groups only the selected category', () async {
      final repository = _FakeSingleCategoryRepository({
        'Animal': [_word('Cat'), _word('ant'), _word('Bear'), _word('ape')],
        'Food': [_word('apple', category: 'Food')],
      });

      final bloc = SingleCategoryBloc(repository, category: 'Animal')
        ..add(const CategoryWordsRequested());

      final state = await bloc.stream.firstWhere(
        (s) => s.status == SingleCategoryStatus.success,
      );

      expect(repository.requestedCategories, ['Animal']);
      expect(state.groupedWords.keys, ['A', 'B', 'C']);
      expect(state.groupedWords['A']!.map((w) => w.word), ['ant', 'ape']);
      expect(state.groupedWords['B']!.map((w) => w.word), ['Bear']);
      expect(state.groupedWords['C']!.map((w) => w.word), ['Cat']);
      expect(state.filteredWords.any((w) => w.word == 'apple'), isFalse);

      await bloc.close();
    });

    test('search filters within the category and regroups results', () async {
      final repository = _FakeSingleCategoryRepository({
        'Animal': [_word('ant'), _word('ape'), _word('Bear'), _word('cat')],
      });

      final bloc = SingleCategoryBloc(repository, category: 'Animal')
        ..add(const CategoryWordsRequested());
      await bloc.stream
          .firstWhere((s) => s.status == SingleCategoryStatus.success);

      bloc.add(const CategorySearchQueryChanged('AN'));
      final state = await bloc.stream.firstWhere((s) => s.searchQuery == 'AN');

      expect(state.filteredWords.map((w) => w.word), ['ant']);
      expect(state.groupedWords.keys, ['A']);
      expect(state.hasNoSearchResults, isFalse);

      await bloc.close();
    });

    test('reports no search results without losing the loaded words',
        () async {
      final repository = _FakeSingleCategoryRepository({
        'Animal': [_word('ant')],
      });

      final bloc = SingleCategoryBloc(repository, category: 'Animal')
        ..add(const CategoryWordsRequested());
      await bloc.stream
          .firstWhere((s) => s.status == SingleCategoryStatus.success);

      bloc.add(const CategorySearchQueryChanged('dog'));
      final state = await bloc.stream.firstWhere((s) => s.searchQuery == 'dog');

      expect(state.filteredWords, isEmpty);
      expect(state.hasNoSearchResults, isTrue);
      expect(state.hasNoSavedWords, isFalse);

      await bloc.close();
    });

    test('closing search clears the query and restores every word', () async {
      final repository = _FakeSingleCategoryRepository({
        'Animal': [_word('ant'), _word('Bear')],
      });

      final bloc = SingleCategoryBloc(repository, category: 'Animal')
        ..add(const CategoryWordsRequested());
      await bloc.stream
          .firstWhere((s) => s.status == SingleCategoryStatus.success);

      bloc.add(const CategorySearchToggled());
      bloc.add(const CategorySearchQueryChanged('ant'));
      await bloc.stream.firstWhere((s) => s.searchQuery == 'ant');

      bloc.add(const CategorySearchToggled());
      final state = await bloc.stream.firstWhere((s) => !s.searchVisible);

      expect(state.searchQuery, '');
      expect(state.filteredWords.map((w) => w.word), ['ant', 'Bear']);

      await bloc.close();
    });

    test('an empty category is reported as empty, not as an error', () async {
      final repository = _FakeSingleCategoryRepository(const {});

      final bloc = SingleCategoryBloc(repository, category: 'Technology')
        ..add(const CategoryWordsRequested());

      final state = await bloc.stream.firstWhere(
        (s) => s.status == SingleCategoryStatus.success,
      );

      expect(state.hasNoSavedWords, isTrue);
      expect(state.hasNoSearchResults, isFalse);

      await bloc.close();
    });

    test('surfaces a user-facing message when loading fails', () async {
      final repository =
          _FakeSingleCategoryRepository(const {}, shouldFail: true);

      final bloc = SingleCategoryBloc(repository, category: 'Animal')
        ..add(const CategoryWordsRequested());

      final state = await bloc.stream.firstWhere(
        (s) => s.status == SingleCategoryStatus.error,
      );

      expect(state.errorMessage, 'Unable to load words in this category.');
      expect(state.errorMessage, isNot(contains('Exception')));

      await bloc.close();
    });
  });
}
