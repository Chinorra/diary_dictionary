import 'package:equatable/equatable.dart';
import '../models/page_model.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object?> get props => [];
}

class LoadBook extends BookEvent {}

class AddPage extends BookEvent {
  final PageModel page;

  const AddPage(this.page);

  @override
  List<Object?> get props => [page];
}

class UpdatePage extends BookEvent {
  final PageModel page;

  const UpdatePage(this.page);

  @override
  List<Object?> get props => [page];
}

class DeletePage extends BookEvent {
  final String pageId;

  const DeletePage(this.pageId);

  @override
  List<Object?> get props => [pageId];
}
