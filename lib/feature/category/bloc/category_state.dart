import 'package:equatable/equatable.dart';

import '../models/category_summary.dart';

enum CategoryStatus { initial, loading, success, error }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<CategorySummary> categories;
  final String? errorMessage;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.errorMessage,
  });

  bool get isBusy =>
      status == CategoryStatus.initial || status == CategoryStatus.loading;

  CategoryState copyWith({
    CategoryStatus? status,
    List<CategorySummary>? categories,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, errorMessage];
}
