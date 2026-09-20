import 'package:drift/drift.dart';

import '../../../database/database.dart';
import '../../category/repository/category_repository.dart';
import '../models/dictionary_lookup.dart';
import 'dictionary_api_client.dart';

class AddWordRepository {
  AddWordRepository({
    required AppDatabase database,
    DictionaryApiClient? apiClient,
    CategoryRepository? categoryRepository,
  })  : _database = database,
        _apiClient = apiClient ?? DictionaryApiClient(),
        _categoryRepository =
            categoryRepository ?? CategoryRepository(database: database);

  final AppDatabase _database;
  final DictionaryApiClient _apiClient;
  final CategoryRepository _categoryRepository;

  /// Categories a word can be filed under, including the ones the user
  /// created on the Category screen.
  Future<List<String>> getCategories() async {
    final categories = await _categoryRepository.getCategories();
    return [for (final category in categories) category.name];
  }

  Future<List<String>> fetchSuggestions(String query) =>
      _apiClient.fetchSuggestions(query);

  Future<DictionaryLookup> translate(String word) => _apiClient.lookup(word);

  Future<int> saveWord({
    required String word,
    required String definition,
    required String example,
    required String partOfSpeech,
    required String category,
    String? imagePath,
  }) {
    return _database.insertWord(
      WordsCompanion.insert(
        word: word.trim(),
        definition: definition.trim(),
        example: Value(example.trim()),
        partOfSpeech: Value(partOfSpeech.trim()),
        category: category,
        imagePath: Value(imagePath),
        createdAt: DateTime.now(),
      ),
    );
  }
}
