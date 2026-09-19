import 'package:drift/drift.dart';

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
