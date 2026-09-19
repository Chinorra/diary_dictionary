import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dictionary/database/database.dart';
import 'package:my_dictionary/feature/add_word/add_word_screen.dart';
import 'package:my_dictionary/feature/common/widget/word_card.dart';
import 'package:my_dictionary/feature/home_screen/home_screen.dart';

Future<int> _saveWord(
  AppDatabase database,
  String word, {
  DateTime? createdAt,
}) {
  return database.insertWord(
    WordsCompanion.insert(
      word: word,
      definition: 'definition of $word',
      partOfSpeech: const Value('noun'),
      category: 'General',
      createdAt: createdAt ?? DateTime.now(),
    ),
  );
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(database: database)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the words actually saved today', (tester) async {
    await _saveWord(database, 'apple');
    await _saveWord(database, 'banana');
    // Saved on an earlier diary day, so it belongs to another page.
    await _saveWord(database, 'yesterday', createdAt: DateTime(2026, 9, 1));

    await pumpHome(tester);

    expect(find.text('apple'), findsOneWidget);
    expect(find.text('banana'), findsOneWidget);
    expect(find.text('yesterday'), findsNothing);
    expect(find.text("You've learned 2 new words today!"), findsOneWidget);
    expect(find.byType(WordCard), findsNWidgets(2));
  });

  testWidgets('shows the empty state when nothing is saved today',
      (tester) async {
    await pumpHome(tester);

    expect(find.byType(WordCard), findsNothing);
    expect(find.text('No words yet'), findsOneWidget);
    expect(
      find.text('No words saved today yet — add your first one!'),
      findsOneWidget,
    );
  });

  testWidgets('shows a word saved while the Add Word screen was open',
      (tester) async {
    await pumpHome(tester);
    expect(find.byType(WordCard), findsNothing);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(AddWordPage), findsOneWidget);

    // Stands in for saving through the Add Word form, which would need the
    // dictionary API; the screen writes the same row and then pops.
    await _saveWord(database, 'serendipity');
    Navigator.of(tester.element(find.byType(AddWordPage))).pop();
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('serendipity'), findsOneWidget);
    expect(find.text("You've learned 1 new word today!"), findsOneWidget);
  });
}
