import 'package:equatable/equatable.dart';
import '../models/page_model.dart';

abstract class BookState extends Equatable {
  const BookState();

  @override
  List<Object?> get props => [];
}

class BookLoading extends BookState {}

class BookLoaded extends BookState {
  final List<PageModel> pages;

  const BookLoaded(this.pages);

  @override
  List<Object?> get props => [pages];
}

class BookError extends BookState {
  final String message;

  const BookError(this.message);

  @override
  List<Object?> get props => [message];
}
