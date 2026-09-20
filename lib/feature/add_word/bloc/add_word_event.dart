import 'package:equatable/equatable.dart';

abstract class AddWordEvent extends Equatable {
  const AddWordEvent();

  @override
  List<Object?> get props => const [];
}

/// Loads the categories the word can be filed under.
class AddWordCategoriesRequested extends AddWordEvent {
  const AddWordCategoriesRequested();
}

class WordQueryChanged extends AddWordEvent {
  final String query;
  const WordQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SuggestionSelected extends AddWordEvent {
  final String suggestion;
  const SuggestionSelected(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

class SuggestionsDismissed extends AddWordEvent {
  const SuggestionsDismissed();
}

class TranslateRequested extends AddWordEvent {
  const TranslateRequested();
}

class CategoryChanged extends AddWordEvent {
  final String category;
  const CategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class DefinitionChanged extends AddWordEvent {
  final String definition;
  const DefinitionChanged(this.definition);

  @override
  List<Object?> get props => [definition];
}

class ExampleChanged extends AddWordEvent {
  final String example;
  const ExampleChanged(this.example);

  @override
  List<Object?> get props => [example];
}

class ImageSelected extends AddWordEvent {
  final String? path;
  const ImageSelected(this.path);

  @override
  List<Object?> get props => [path];
}

class ImageRemoved extends AddWordEvent {
  const ImageRemoved();
}

class SaveRequested extends AddWordEvent {
  const SaveRequested();
}
