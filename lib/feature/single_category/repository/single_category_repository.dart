import '../../../database/database.dart';

class SingleCategoryRepository {
  SingleCategoryRepository({required AppDatabase database})
      : _database = database;

  final AppDatabase _database;

  Future<List<Word>> getWordsByCategory(String category) =>
      _database.getWordsByCategory(category);
}
