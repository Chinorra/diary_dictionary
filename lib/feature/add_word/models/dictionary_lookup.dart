class DictionaryLookup {
  final String word;
  final String definition;
  final String example;
  final String partOfSpeech;

  const DictionaryLookup({
    required this.word,
    required this.definition,
    required this.example,
    required this.partOfSpeech,
  });
}

class DictionaryException implements Exception {
  final String message;
  const DictionaryException(this.message);

  @override
  String toString() => message;
}
