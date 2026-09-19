import '../../../database/database.dart';

class HomeRepository {
  HomeRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<List<Word>> getWordsByDate(DateTime date) =>
      _database.getWordsByDate(date);
}
