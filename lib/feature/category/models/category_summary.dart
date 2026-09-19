import 'package:equatable/equatable.dart';

import '../../add_word/models/word_category.dart';

/// One browsable category plus how many saved words it currently holds.
class CategorySummary extends Equatable {
  const CategorySummary({required this.name, required this.wordCount});

  final String name;
  final int wordCount;

  bool get isEmpty => wordCount == 0;

  @override
  List<Object?> get props => [name, wordCount];
}

/// Builds the browsable category list from the single source of truth
/// ([kWordCategories]) combined with the counts stored in the database.
///
/// Every known category is kept even when it holds no words, so the user can
/// still open it. Categories that only exist in saved data — for example after
/// the canonical list changed — are appended so their words stay reachable.
List<CategorySummary> buildCategorySummaries(Map<String, int> wordCounts) {
  final summaries = <CategorySummary>[
    for (final name in kWordCategories)
      CategorySummary(name: name, wordCount: wordCounts[name] ?? 0),
  ];

  final known = kWordCategories.toSet();
  final extras = wordCounts.keys.where((name) => !known.contains(name)).toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  for (final name in extras) {
    summaries.add(CategorySummary(name: name, wordCount: wordCounts[name] ?? 0));
  }

  return summaries;
}
