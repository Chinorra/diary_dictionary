import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc(this._repository) : super(const CategoryState()) {
    on<CategoriesRequested>(_onCategoriesRequested);
    on<CategoryCreationRequested>(_onCategoryCreationRequested);
  }

  final CategoryRepository _repository;

  Future<void> _onCategoriesRequested(
    CategoriesRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(
      status: CategoryStatus.loading,
      clearErrorMessage: true,
    ));

    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(
        status: CategoryStatus.success,
        categories: categories,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: 'Unable to load your categories.',
      ));
    }
  }

  Future<void> _onCategoryCreationRequested(
    CategoryCreationRequested event,
    Emitter<CategoryState> emit,
  ) async {
    if (state.isCreating) return;

    emit(state.copyWith(
      isCreating: true,
      clearCreationErrorMessage: true,
    ));

    try {
      final categories = await _repository.createCategory(event.name);
      emit(state.copyWith(
        status: CategoryStatus.success,
        categories: categories,
        isCreating: false,
      ));
    } on CategoryNameException catch (error) {
      emit(state.copyWith(
        isCreating: false,
        creationErrorMessage: error.message,
      ));
    } catch (_) {
      // The list already on screen stays usable; only the new category failed.
      emit(state.copyWith(
        isCreating: false,
        creationErrorMessage: 'Unable to create a new category.',
      ));
    }
  }
}
