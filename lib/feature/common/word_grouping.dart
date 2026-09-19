import '../../database/database.dart';

const String kOtherSectionKey = '#';

List<Word> filterWords(List<Word> words, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return List<Word>.of(words);
  return words
      .where((word) => word.word.toLowerCase().contains(normalized))
      .toList(growable: false);
}

List<Word> sortWords(List<Word> words) {
  final sorted = List<Word>.of(words);
  sorted.sort((a, b) {
    final byLowercase = a.word.toLowerCase().compareTo(b.word.toLowerCase());
    return byLowercase != 0 ? byLowercase : a.word.compareTo(b.word);
  });
  return sorted;
}

Map<String, List<Word>> groupWords(List<Word> words) {
  final grouped = <String, List<Word>>{};
  for (final word in words) {
    grouped.putIfAbsent(sectionKeyOf(word.word), () => <Word>[]).add(word);
  }
  final keys = grouped.keys.toList()..sort();
  return {for (final key in keys) key: grouped[key]!};
}

String sectionKeyOf(String word) {
  final trimmed = word.trimLeft();
  if (trimmed.isEmpty) return kOtherSectionKey;
  final first = trimmed[0].toUpperCase();
  return RegExp(r'^[A-Z]$').hasMatch(first) ? first : kOtherSectionKey;
}
