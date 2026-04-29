import 'package:bloc/bloc.dart';
import 'book_event.dart';
import 'book_state.dart';
import '../repository/book_repository.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookRepository repository;

  BookBloc(this.repository) : super(BookLoading()) {
    on<LoadBook>(_onLoad);
    on<AddPage>(_onAdd);
    on<UpdatePage>(_onUpdate);
    on<DeletePage>(_onDelete);
  }

  Future<void> _onLoad(
    LoadBook event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final pages = await repository.getAll();
      emit(BookLoaded(pages));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onAdd(
    AddPage event,
    Emitter<BookState> emit,
  ) async {
    try {
      await repository.create(event.page);
      add(LoadBook());
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdatePage event,
    Emitter<BookState> emit,
  ) async {
    try {
      await repository.update(event.page);
      add(LoadBook());
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeletePage event,
    Emitter<BookState> emit,
  ) async {
    try {
      await repository.delete(event.pageId);
      add(LoadBook());
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }
}
