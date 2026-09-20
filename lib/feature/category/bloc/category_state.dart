import 'package:equatable/equatable.dart';

import '../models/category_summary.dart';

enum CategoryStatus { initial, loading, success, error }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<CategorySummary> categories;
  final String? errorMessage;

  /// True while a new category is being stored, so the header action cannot
  /// be triggered twice.
  final bool isCreating;

  /// Set when creating a category failed. Kept apart from [errorMessage] so a
  /// failed creation leaves the loaded list on screen.
  final String? creationErrorMessage;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.isCreating = false,
    this.creationErrorMessage,
  });

  bool get isBusy =>
      status == CategoryStatus.initial || status == CategoryStatus.loading;

  CategoryState copyWith({
    CategoryStatus? status,
    List<CategorySummary>? categories,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isCreating,
    String? creationErrorMessage,
    bool clearCreationErrorMessage = false,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      isCreating: isCreating ?? this.isCreating,
      creationErrorMessage: clearCreationErrorMessage
          ? null
          : creationErrorMessage ?? this.creationErrorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, categories, errorMessage, isCreating, creationErrorMessage];
}
