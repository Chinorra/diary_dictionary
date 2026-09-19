import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dictionary/database/database.dart';
import 'package:my_dictionary/feature/home_screen/home_screen.dart';
import 'package:my_dictionary/feature/word_detail/word_detail_screen.dart';

void main() {
  late AppDatabase database;
  late Word saved;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    final id = await database.insertWord(
      WordsCompanion.insert(
        word: 'apple',
        definition: 'A round fruit.',
        example: const Value('I ate an apple.'),
        partOfSpeech: const Value('noun'),
        category: 'Food',
        createdAt: DateTime.now(),
      ),
    );
    saved = (await database.findById(id))!;
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpDetail(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: WordDetailScreen(word: saved, database: database)),
    );
    await tester.pumpAndSettle();
  }

  /// The text field under a given label.
  Finder fieldFor(String label) => find.descendant(
        of: find.ancestor(
          of: find.text(label),
          matching: find.byType(Column),
        ).first,
        matching: find.byType(TextField),
      );

  /// The edit icon sitting next to a given label.
  Finder editIconFor(String label) => find.descendant(
        of: find.ancestor(
          of: find.text(label),
          matching: find.byType(Row),
        ).first,
        matching: find.byIcon(Icons.edit_outlined),
      );

  /// Scrolls a target into the 800x600 test viewport before tapping it.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('shows everything saved about the word', (tester) async {
    await pumpDetail(tester);

    expect(find.text('Word Detail'), findsOneWidget);
    expect(find.text('A round fruit.'), findsOneWidget);
    expect(find.text('I ate an apple.'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);
    expect(find.text('noun'), findsWidgets);
    // Every editable field offers its own edit icon.
    expect(find.byIcon(Icons.edit_outlined), findsNWidgets(5));
  });

  testWidgets('fields are read-only until their edit icon is tapped',
      (tester) async {
    await pumpDetail(tester);

    final definition = tester.widget<TextField>(fieldFor('Definition'));
    expect(definition.readOnly, isTrue);

    await tapVisible(tester, editIconFor('Definition'));

    expect(tester.widget<TextField>(fieldFor('Definition')).readOnly, isFalse);
    // Only the tapped field unlocks.
    expect(
      tester.widget<TextField>(fieldFor('Example sentence')).readOnly,
      isTrue,
    );
  });

  testWidgets('saving an edited field writes it to the database',
      (tester) async {
    await pumpDetail(tester);

    // Nothing to save before anything is edited.
    final saveButton = find.widgetWithText(ElevatedButton, 'Save changes');
    expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNull);

    await tapVisible(tester, editIconFor('Definition'));
    await tester.enterText(fieldFor('Definition'), 'A crisp orchard fruit.');
    await tester.pumpAndSettle();

    expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNotNull);

    await tapVisible(tester, saveButton);

    final stored = await database.findById(saved.id);
    expect(stored!.definition, 'A crisp orchard fruit.');
    // Untouched fields and the diary day survive the edit.
    expect(stored.example, 'I ate an apple.');
    expect(stored.createdAt, saved.createdAt);
    expect(find.text('Changes saved'), findsOneWidget);
    // The field locks itself again once saved.
    expect(tester.widget<TextField>(fieldFor('Definition')).readOnly, isTrue);
  });

  testWidgets('discarding restores the stored value', (tester) async {
    await pumpDetail(tester);

    await tapVisible(tester, editIconFor('Example sentence'));
    await tester.enterText(fieldFor('Example sentence'), 'Something else.');
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Discard changes'));

    expect(find.text('I ate an apple.'), findsOneWidget);
    expect(find.text('Something else.'), findsNothing);
    expect((await database.findById(saved.id))!.example, 'I ate an apple.');
  });

  testWidgets('opens from a word card on the home screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(database: database)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('apple'));
    await tester.pumpAndSettle();

    expect(find.byType(WordDetailScreen), findsOneWidget);
    expect(find.text('Word Detail'), findsOneWidget);
  });
}
