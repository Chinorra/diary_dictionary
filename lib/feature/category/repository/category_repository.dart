import '../../../database/database.dart';
import '../models/category_summary.dart';

/// Thrown when a category cannot be created under the requested name.
class CategoryNameException implements Exception {
  final String message;
  const CategoryNameException(this.message);

  @override
  String toString() => message;
}

class CategoryRepository {
  CategoryRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<List<CategorySummary>> getCategories() async {
    final wordCounts = await _database.getWordCountByCategory();
    final userCategories = await _database.getUserCategoryNames();
    return buildCategorySummaries(wordCounts, userCategories: userCategories);
  }

  /// Stores a new empty category called [name] and returns the refreshed list.
  ///
  /// The name is checked against the stored categories rather than against
  /// whatever the screen last loaded, so two attempts cannot both get through.
  Future<List<CategorySummary>> createCategory(String name) async {
    final cleanName = sanitizeCategoryName(name);
    if (cleanName.isEmpty) {
      throw const CategoryNameException('Please enter a category name.');
    }

    final existing = await getCategories();
    if (isDuplicateCategoryName(existing.map((s) => s.name), cleanName)) {
      throw const CategoryNameException('That category already exists.');
    }

    await _database.insertUserCategory(cleanName);
    return getCategories();
  }
}
