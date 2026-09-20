import 'package:equatable/equatable.dart';

import '../../add_word/models/word_category.dart';

/// Longest category name the user can type, matching the database column.
const int kMaxCategoryNameLength = 64;

/// One browsable category plus how many saved words it currently holds.
class CategorySummary extends Equatable {
  const CategorySummary({required this.name, required this.wordCount});

  final String name;
  final int wordCount;

  bool get isEmpty => wordCount == 0;

  @override
  List<Object?> get props => [name, wordCount];
}

/// Builds the browsable category list from the categories the user created,
/// the canonical list ([kWordCategories]) and the counts stored in the
/// database.
///
/// User-created categories come first, newest first, so a category created
/// from the header is visible straight away. Every known category is kept even
/// when it holds no words, so the user can still open it. Categories that only
/// exist in saved data — for example after the canonical list changed — are
/// appended so their words stay reachable.
List<CategorySummary> buildCategorySummaries(
  Map<String, int> wordCounts, {
  List<String> userCategories = const [],
}) {
  final canonical = kWordCategories.toSet();
  final ownNames = <String>[
    for (final name in userCategories)
      if (!canonical.contains(name)) name,
  ];

  final summaries = <CategorySummary>[
    for (final name in ownNames)
      CategorySummary(name: name, wordCount: wordCounts[name] ?? 0),
    for (final name in kWordCategories)
      CategorySummary(name: name, wordCount: wordCounts[name] ?? 0),
  ];

  final known = {...canonical, ...ownNames};
  final extras = wordCounts.keys.where((name) => !known.contains(name)).toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  for (final name in extras) {
    summaries.add(CategorySummary(name: name, wordCount: wordCounts[name] ?? 0));
  }

  return summaries;
}

/// Cleans up a name typed by the user: outer spaces removed and runs of
/// whitespace collapsed, so '  My   Words ' and 'My Words' are one category.
String sanitizeCategoryName(String raw) =>
    raw.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Whether [name] is already taken, ignoring case and surrounding spaces.
bool isDuplicateCategoryName(Iterable<String> existingNames, String name) {
  final candidate = sanitizeCategoryName(name).toLowerCase();
  return existingNames
      .any((existing) => sanitizeCategoryName(existing).toLowerCase() == candidate);
}
