import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dictionary/database/database.dart';
import 'package:my_dictionary/feature/all_word/all_word_screen.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.insertWord(
      WordsCompanion.insert(
        word: 'apple',
        definition: 'A round fruit.',
        example: const Value('I ate an apple.'),
        partOfSpeech: const Value('noun'),
        category: 'Food',
        createdAt: DateTime.now(),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  /// Pushes the screen so the app bar gets a real back button.
  Future<void> pumpAllWords(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AllWordScreen(database: database),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the title shares one line with the back button',
      (tester) async {
    await pumpAllWords(tester);

    final title = find.text('All word');
    final back = find.byType(BackButton);

    expect(title, findsOneWidget);
    expect(back, findsOneWidget);
    // Same row: vertically centred together, title to the right of the arrow.
    expect(
      tester.getCenter(title).dy,
      moreOrLessEquals(tester.getCenter(back).dy, epsilon: 1),
    );
    expect(
      tester.getTopLeft(title).dx,
      greaterThan(tester.getBottomRight(back).dx - 1),
    );
  });

  testWidgets('no longer shows the Vocabulary Diary line', (tester) async {
    await pumpAllWords(tester);

    expect(find.text('Vocabulary Diary'), findsNothing);
  });

  testWidgets('keeps the search action and the word list', (tester) async {
    await pumpAllWords(tester);

    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.text('apple'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });
}
