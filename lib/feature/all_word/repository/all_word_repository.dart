import '../../../database/database.dart';

class AllWordRepository {
  AllWordRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<List<Word>> getAllWords() => _database.getAllWords();
}
