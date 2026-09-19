import 'package:equatable/equatable.dart';

abstract class AllWordEvent extends Equatable {
  const AllWordEvent();

  @override
  List<Object?> get props => const [];
}

class AllWordsRequested extends AllWordEvent {
  const AllWordsRequested();
}

class SearchToggled extends AllWordEvent {
  const SearchToggled();
}

class SearchQueryChanged extends AllWordEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}
