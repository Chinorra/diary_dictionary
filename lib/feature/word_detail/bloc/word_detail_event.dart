import 'package:equatable/equatable.dart';

import 'word_detail_state.dart';

abstract class WordDetailEvent extends Equatable {
  const WordDetailEvent();

  @override
  List<Object?> get props => const [];
}

/// Unlocks a field for editing, or locks it again, from its edit icon.
class FieldEditToggled extends WordDetailEvent {
  final WordDetailField field;

  const FieldEditToggled(this.field);

  @override
  List<Object?> get props => [field];
}

class FieldChanged extends WordDetailEvent {
  final WordDetailField field;
  final String value;

  const FieldChanged(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

/// Drops every unsaved edit and locks the fields again.
class EditsDiscarded extends WordDetailEvent {
  const EditsDiscarded();
}

class WordSaveRequested extends WordDetailEvent {
  const WordSaveRequested();
}
