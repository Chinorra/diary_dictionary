import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dictionary/database/database.dart';
import 'package:my_dictionary/feature/category/category_screen.dart';
import 'package:my_dictionary/feature/single_category/single_category_screen.dart';

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

  /// Pushes [screen] so its app bar gets a real back button.
  Future<void> pumpPushed(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => screen),
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

  /// The title and the back arrow are centred on the same row, with the title
  /// to the right of the arrow.
  void expectTitleOnBackButtonLine(WidgetTester tester, Finder title) {
    final back = find.byType(BackButton);
    expect(title, findsOneWidget);
    expect(back, findsOneWidget);
    expect(
      tester.getCenter(title).dy,
      moreOrLessEquals(tester.getCenter(back).dy, epsilon: 1),
    );
    expect(
      tester.getTopLeft(title).dx,
      greaterThan(tester.getBottomRight(back).dx - 1),
    );
  }

  testWidgets('Categories title shares one line with the back button',
      (tester) async {
    await pumpPushed(tester, CategoryScreen(database: database));

    expectTitleOnBackButtonLine(tester, find.text('Categories'));
    expect(find.text('Vocabulary Diary'), findsNothing);
  });

  testWidgets('a category title shares one line with the back button',
      (tester) async {
    await pumpPushed(
      tester,
      SingleCategoryScreen(category: 'Food', database: database),
    );

    // The category name is the title now; the 'Category' eyebrow is gone.
    expectTitleOnBackButtonLine(tester, find.text('Food').first);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.text('apple'), findsOneWidget);
  });
}
