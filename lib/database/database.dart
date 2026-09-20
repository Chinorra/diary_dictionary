import 'package:drift/drift.dart';

import '../feature/common/diary_date.dart';
import 'connection/connection.dart' as connection;

part 'database.g.dart';

class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text().withLength(min: 1, max: 128)();
  TextColumn get definition => text()();
  TextColumn get example => text().withDefault(const Constant(''))();
  TextColumn get partOfSpeech => text().withDefault(const Constant(''))();
  TextColumn get category => text()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Categories the user created on the Category screen.
///
/// Categories otherwise only exist through the words that use them, so an
/// empty category needs a row of its own to survive a restart.
class UserCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64).unique()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Words, UserCategories])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(connection.openConnection());

  AppDatabase.forTesting(super.executor);

  static final AppDatabase instance = AppDatabase._();

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // Saved words are left untouched; the new table only adds a place to
          // keep categories that hold no words yet.
          if (from < 2) {
            await m.createTable(userCategories);
          }
        },
      );

  Future<int> insertWord(WordsCompanion word) => into(words).insert(word);

  Future<List<Word>> getAllWords() =>
      (select(words)..orderBy([(w) => OrderingTerm.desc(w.createdAt)])).get();

  Stream<List<Word>> watchAllWords() =>
      (select(words)..orderBy([(w) => OrderingTerm.desc(w.createdAt)])).watch();

  /// Words saved on the calendar day of [date], newest first.
  Future<List<Word>> getWordsByDate(DateTime date) {
    final start = startOfDiaryDay(date);
    final end = startOfNextDiaryDay(date);
    return (select(words)
          ..where((w) =>
              w.createdAt.isBiggerOrEqualValue(start) &
              w.createdAt.isSmallerThanValue(end))
          ..orderBy([(w) => OrderingTerm.desc(w.createdAt)]))
        .get();
  }

  Future<Word?> findById(int id) =>
      (select(words)..where((w) => w.id.equals(id))).getSingleOrNull();

  /// Updates the user-editable fields of a saved word. [Words.createdAt] and
  /// [Words.imagePath] are left untouched so the word keeps its diary day.
  Future<int> updateWordFields({
    required int id,
    required String word,
    required String definition,
    required String example,
    required String partOfSpeech,
    required String category,
  }) {
    return (update(words)..where((w) => w.id.equals(id))).write(
      WordsCompanion(
        word: Value(word),
        definition: Value(definition),
        example: Value(example),
        partOfSpeech: Value(partOfSpeech),
        category: Value(category),
      ),
    );
  }

  Future<Word?> findByWord(String word) =>
      (select(words)..where((w) => w.word.equals(word))).getSingleOrNull();

  Future<List<Word>> getWordsByCategory(String category) => (select(words)
        ..where((w) => w.category.equals(category))
        ..orderBy([(w) => OrderingTerm.desc(w.createdAt)]))
      .get();

  /// Categories the user created, newest first so a fresh one is easy to find.
  ///
  /// Ordered by [UserCategories.id] rather than the timestamp, so categories
  /// created in the same millisecond still come back in creation order.
  Future<List<String>> getUserCategoryNames() async {
    final rows = await (select(userCategories)
          ..orderBy([(c) => OrderingTerm.desc(c.id)]))
        .get();
    return rows.map((row) => row.name).toList(growable: false);
  }

  Future<void> insertUserCategory(String name) async {
    await into(userCategories).insert(
      UserCategoriesCompanion.insert(name: name, createdAt: DateTime.now()),
    );
  }

  Future<Map<String, int>> getWordCountByCategory() async {
    final wordCount = words.id.count();
    final query = selectOnly(words)
      ..addColumns([words.category, wordCount])
      ..groupBy([words.category]);

    final rows = await query.get();
    return {
      for (final row in rows)
        row.read(words.category)!: row.read(wordCount) ?? 0,
    };
  }
}
