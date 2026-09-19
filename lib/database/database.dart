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

@DriftDatabase(tables: [Words])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(connection.openConnection());

  AppDatabase.forTesting(super.executor);

  static final AppDatabase instance = AppDatabase._();

  @override
  int get schemaVersion => 1;

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
