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

  /// Opens the Category screen and taps the floating action button.
  Future<void> openNewCategorySheet(WidgetTester tester) async {
    await pumpPushed(tester, CategoryScreen(database: database));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  }

  testWidgets('the button opens a sheet that names the new category',
      (tester) async {
    await openNewCategorySheet(tester);
    expect(find.text('New category'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'My Words');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('New category'), findsNothing);
    expect(find.text('My Words'), findsOneWidget);
    expect(find.text('0 words'), findsWidgets);
    // Stored, so it is still there the next time the screen is opened.
    expect(await database.getUserCategoryNames(), ['My Words']);
  });

  testWidgets('the newest category is the first card', (tester) async {
    await openNewCategorySheet(tester);
    await tester.enterText(find.byType(TextField), 'Hobby');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Sports');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(
      tester.getCenter(find.text('Sports')).dy,
      lessThan(tester.getCenter(find.text('Hobby')).dy),
    );
  });

  testWidgets('a name already in use is refused with a message',
      (tester) async {
    await openNewCategorySheet(tester);

    // 'Food' is a canonical category and already holds the saved word.
    await tester.enterText(find.byType(TextField), 'food');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('That category already exists.'), findsOneWidget);
    // The sheet stays open so the name can be corrected.
    expect(find.text('New category'), findsOneWidget);
    expect(await database.getUserCategoryNames(), isEmpty);
  });

  testWidgets('nothing is created without a name', (tester) async {
    await openNewCategorySheet(tester);

    final addButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Add'),
    );
    expect(addButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Add'))
          .onPressed,
      isNull,
    );

    // Tapping outside the sheet closes it without creating anything.
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('New category'), findsNothing);
    expect(await database.getUserCategoryNames(), isEmpty);
  });

  testWidgets('the sheet has one full-width Add button', (tester) async {
    await openNewCategorySheet(tester);

    expect(find.widgetWithText(ElevatedButton, 'Add'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);

    // Full width: as wide as the name field above it.
    final fieldWidth = tester
        .getSize(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(Container),
              )
              .first,
        )
        .width;
    final buttonWidth =
        tester.getSize(find.widgetWithText(ElevatedButton, 'Add')).width;
    expect(buttonWidth, moreOrLessEquals(fieldWidth, epsilon: 1));
  });

  testWidgets('a created category opens like any other', (tester) async {
    await openNewCategorySheet(tester);
    await tester.enterText(find.byType(TextField), 'Hobby');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hobby'));
    await tester.pumpAndSettle();

    expect(find.byType(SingleCategoryScreen), findsOneWidget);
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
