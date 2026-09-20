import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dictionary/database/database.dart';
import 'package:my_dictionary/feature/add_word/add_word_screen.dart';
import 'package:my_dictionary/feature/add_word/models/word_category.dart';
import 'package:my_dictionary/feature/add_word/repository/add_word_repository.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpAddWord(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AddWordPage(database: database)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openCategoryPicker(WidgetTester tester) async {
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
  }

  group('AddWordRepository.getCategories', () {
    test('includes the categories the user created, newest first', () async {
      final repository = AddWordRepository(database: database);
      await database.insertUserCategory('Hobby');
      await database.insertUserCategory('Sports');

      final categories = await repository.getCategories();

      expect(categories.take(2), ['Sports', 'Hobby']);
      expect(categories, containsAll(kWordCategories));
    });

    test('is the canonical list when nothing was created', () async {
      final repository = AddWordRepository(database: database);

      expect(await repository.getCategories(), kWordCategories);
    });
  });

  testWidgets('the picker offers a category created on the Category screen',
      (tester) async {
    await database.insertUserCategory('Hobby');

    await pumpAddWord(tester);
    await openCategoryPicker(tester);

    expect(find.text('Hobby'), findsWidgets);
  });

  testWidgets('a created category can be picked for the word', (tester) async {
    await database.insertUserCategory('Hobby');

    await pumpAddWord(tester);
    await openCategoryPicker(tester);
    await tester.tap(find.text('Hobby').last);
    await tester.pumpAndSettle();

    // The closed picker now shows the chosen category.
    expect(find.text('Hobby'), findsOneWidget);
    expect(find.text(kDefaultWordCategory), findsNothing);
  });

  testWidgets('a word saved before still picks its stored category',
      (tester) async {
    // A category that only exists through a saved word stays selectable.
    await database.insertWord(
      WordsCompanion.insert(
        word: 'ant',
        definition: 'An insect.',
        example: const Value(''),
        partOfSpeech: const Value('noun'),
        category: 'Animal',
        createdAt: DateTime.now(),
      ),
    );

    await pumpAddWord(tester);
    await openCategoryPicker(tester);

    expect(find.text('Animal'), findsWidgets);
  });
}
