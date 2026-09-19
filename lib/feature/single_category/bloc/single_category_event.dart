import 'package:equatable/equatable.dart';

abstract class SingleCategoryEvent extends Equatable {
  const SingleCategoryEvent();

  @override
  List<Object?> get props => const [];
}

class CategoryWordsRequested extends SingleCategoryEvent {
  const CategoryWordsRequested();
}

class CategorySearchToggled extends SingleCategoryEvent {
  const CategorySearchToggled();
}

class CategorySearchQueryChanged extends SingleCategoryEvent {
  final String query;
  const CategorySearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}
