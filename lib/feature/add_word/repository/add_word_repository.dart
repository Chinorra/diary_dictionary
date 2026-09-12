import 'package:drift/drift.dart';

import '../../../database/database.dart';
import '../models/dictionary_lookup.dart';
import 'dictionary_api_client.dart';

class AddWordRepository {
  AddWordRepository({
    required AppDatabase database,
    DictionaryApiClient? apiClient,
  })  : _database = database,
        _apiClient = apiClient ?? DictionaryApiClient();

  final AppDatabase _database;
  final DictionaryApiClient _apiClient;

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
