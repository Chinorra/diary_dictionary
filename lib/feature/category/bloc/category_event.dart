import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => const [];
}

class CategoriesRequested extends CategoryEvent {
  const CategoriesRequested();
}
