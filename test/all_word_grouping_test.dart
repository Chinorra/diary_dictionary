import 'package:flutter_test/flutter_test.dart';
import 'package:my_dictionary/database/database.dart';
import 'package:my_dictionary/feature/common/word_grouping.dart';

Word _word(String value) => Word(
      id: value.hashCode,
      word: value,
      definition: 'definition of $value',
      example: '',
      partOfSpeech: 'noun',
      category: 'General',
      createdAt: DateTime(2026, 9, 13),
    );

void main() {
  group('sortWords', () {
    test('sorts case-insensitively and keeps original capitalization', () {
      final sorted = sortWords(
        ['Zoo', 'apple', 'Banana', 'application', 'book'].map(_word).toList(),
      );

      expect(
        sorted.map((w) => w.word),
        ['apple', 'application', 'Banana', 'book', 'Zoo'],
      );
    });
  });

  group('groupWords', () {
    test('groups by first letter and skips letters without words', () {
      final grouped = groupWords(
        sortWords(['banana', 'apple', 'computer', 'application']
            .map(_word)
            .toList()),
      );

      expect(grouped.keys, ['A', 'B', 'C']);
      expect(grouped['A']!.map((w) => w.word), ['apple', 'application']);
      expect(grouped['B']!.map((w) => w.word), ['banana']);
      expect(grouped.containsKey('D'), isFalse);
    });

    test('buckets words not starting with a letter under #', () {
      final grouped = groupWords([_word('3D'), _word('apple')]);

      expect(grouped[kOtherSectionKey]!.map((w) => w.word), ['3D']);
      expect(grouped['A']!.map((w) => w.word), ['apple']);
    });
  });

  group('filterWords', () {
    test('matches words containing the query, case-insensitively', () {
      final words =
          ['apple', 'application', 'banana', 'computer'].map(_word).toList();

      expect(
        filterWords(words, 'APP').map((w) => w.word),
        ['apple', 'application'],
      );
    });

    test('returns every word for a blank query', () {
      final words = ['apple', 'banana'].map(_word).toList();

      expect(filterWords(words, '   ').length, 2);
    });

    test('does not match against definitions', () {
      final words = [_word('apple')];

      expect(filterWords(words, 'definition'), isEmpty);
    });
  });
}
