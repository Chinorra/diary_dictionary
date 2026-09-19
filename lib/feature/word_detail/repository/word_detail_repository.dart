import '../../../database/database.dart';

class WordDetailRepository {
  WordDetailRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<Word?> getWord(int id) => _database.findById(id);

  /// Writes the user's edits and returns the stored word.
  Future<Word?> updateWord({
    required int id,
    required String word,
    required String definition,
    required String example,
    required String partOfSpeech,
    required String category,
  }) async {
    await _database.updateWordFields(
      id: id,
      word: word,
      definition: definition,
      example: example,
      partOfSpeech: partOfSpeech,
      category: category,
    );
    return _database.findById(id);
  }
}
