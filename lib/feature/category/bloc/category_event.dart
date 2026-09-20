import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => const [];
}

class CategoriesRequested extends CategoryEvent {
  const CategoriesRequested();
}

/// Creates a new empty category from the name the user typed.
class CategoryCreationRequested extends CategoryEvent {
  final String name;

  const CategoryCreationRequested(this.name);

  @override
  List<Object?> get props => [name];
}
