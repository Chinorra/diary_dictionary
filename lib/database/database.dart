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
  AppDatabase() : super(connection.openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<int> insertWord(WordsCompanion word) => into(words).insert(word);

  Future<List<Word>> getAllWords() =>
      (select(words)..orderBy([(w) => OrderingTerm.desc(w.createdAt)])).get();

  Stream<List<Word>> watchAllWords() =>
      (select(words)..orderBy([(w) => OrderingTerm.desc(w.createdAt)])).watch();

  Future<Word?> findByWord(String word) =>
      (select(words)..where((w) => w.word.equals(word))).getSingleOrNull();
}
