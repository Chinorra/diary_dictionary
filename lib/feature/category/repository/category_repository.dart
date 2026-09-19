import '../../../database/database.dart';
import '../models/category_summary.dart';

class CategoryRepository {
  CategoryRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<List<CategorySummary>> getCategories() async {
    final wordCounts = await _database.getWordCountByCategory();
    return buildCategorySummaries(wordCounts);
  }
}
