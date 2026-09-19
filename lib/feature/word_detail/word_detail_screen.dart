import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../database/database.dart';
import '../add_word/models/word_category.dart';
import '../common/color/color.dart';
import '../common/diary_date.dart';
import 'bloc/word_detail_bloc.dart';
import 'bloc/word_detail_event.dart';
import 'bloc/word_detail_state.dart';
import 'repository/word_detail_repository.dart';

/// Shows everything saved about one word. Fields are read-only until the user
/// taps the edit icon next to the one they want to change.
class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({super.key, required this.word, this.database});

  final Word word;
  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WordDetailBloc(
        WordDetailRepository(database: database ?? AppDatabase.instance),
        word,
      ),
      child: const _WordDetailView(),
    );
  }
}

class _WordDetailView extends StatefulWidget {
  const _WordDetailView();

  @override
  State<_WordDetailView> createState() => _WordDetailViewState();
}

class _WordDetailViewState extends State<_WordDetailView> {
  static const _textFields = [
    WordDetailField.word,
    WordDetailField.partOfSpeech,
    WordDetailField.definition,
    WordDetailField.example,
  ];

  final Map<WordDetailField, TextEditingController> _controllers = {
    for (final field in _textFields) field: TextEditingController(),
  };
  final Map<WordDetailField, FocusNode> _focusNodes = {
    for (final field in _textFields) field: FocusNode(),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncControllers(WordDetailState state) {
    for (final field in _textFields) {
      final controller = _controllers[field]!;
      final value = state.valueOf(field);
      if (controller.text != value) {
        controller.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
    }
  }

  /// Fields unlocked on the previous build, so newly unlocked ones can take
  /// the cursor.
  Set<WordDetailField> _lastEditing = const {};

  /// Puts the cursor in a field as soon as its edit icon unlocks it.
  void _focusUnlockedFields(WordDetailState state) {
    for (final field in _textFields) {
      final wasEditing = _lastEditing.contains(field);
      if (state.isEditing(field) && !wasEditing) {
        _focusNodes[field]!.requestFocus();
      } else if (!state.isEditing(field) && wasEditing) {
        _focusNodes[field]!.unfocus();
      }
    }
    _lastEditing = state.editingFields;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WordDetailBloc, WordDetailState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.editingFields != current.editingFields ||
          previous.errorMessage != current.errorMessage ||
          previous.validationError != current.validationError,
      listener: (context, state) {
        _focusUnlockedFields(state);
        if (state.status == WordDetailStatus.saved) {
          FocusManager.instance.primaryFocus?.unfocus();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Changes saved')));
          return;
        }
        final message = state.errorMessage ?? state.validationError;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        _syncControllers(state);
        return Scaffold(
          backgroundColor: kBackground,
          appBar: AppBar(
            backgroundColor: kSurface,
            elevation: 0,
            surfaceTintColor: kSurface,
            iconTheme: const IconThemeData(color: kTextPrimary),
            titleSpacing: 0,
            title: const Text(
              'Word Detail',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            shape: const Border(bottom: BorderSide(color: kDivider)),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WordHeader(state: state),
                  const SizedBox(height: 24),
                  _EditableTextField(
                    label: 'Word',
                    field: WordDetailField.word,
                    controller: _controllers[WordDetailField.word]!,
                    focusNode: _focusNodes[WordDetailField.word]!,
                    isEditing: state.isEditing(WordDetailField.word),
                    hint: 'The word',
                    minLines: 1,
                  ),
                  const SizedBox(height: 20),
                  _EditableTextField(
                    label: 'Part of speech',
                    field: WordDetailField.partOfSpeech,
                    controller: _controllers[WordDetailField.partOfSpeech]!,
                    focusNode: _focusNodes[WordDetailField.partOfSpeech]!,
                    isEditing: state.isEditing(WordDetailField.partOfSpeech),
                    hint: 'noun, verb, adjective…',
                    minLines: 1,
                  ),
                  const SizedBox(height: 20),
                  _CategoryField(
                    category: state.category,
                    isEditing: state.isEditing(WordDetailField.category),
                  ),
                  const SizedBox(height: 20),
                  _EditableTextField(
                    label: 'Definition',
                    field: WordDetailField.definition,
                    controller: _controllers[WordDetailField.definition]!,
                    focusNode: _focusNodes[WordDetailField.definition]!,
                    isEditing: state.isEditing(WordDetailField.definition),
                    hint: 'No definition saved',
                    minLines: 3,
                  ),
                  const SizedBox(height: 20),
                  _EditableTextField(
                    label: 'Example sentence',
                    field: WordDetailField.example,
                    controller: _controllers[WordDetailField.example]!,
                    focusNode: _focusNodes[WordDetailField.example]!,
                    isEditing: state.isEditing(WordDetailField.example),
                    hint: 'No example saved',
                    minLines: 2,
                  ),
                  if (state.saved.imagePath != null &&
                      state.saved.imagePath!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const _FieldLabel('Image'),
                    const SizedBox(height: 8),
                    _WordImage(path: state.saved.imagePath!),
                  ],
                  const SizedBox(height: 28),
                  _SaveBar(state: state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _WordHeader extends StatelessWidget {
  const _WordHeader({required this.state});

  final WordDetailState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.word.isEmpty ? '—' : state.word,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (state.partOfSpeech.isNotEmpty)
                      _Chip(label: state.partOfSpeech),
                    _Chip(label: state.category),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Added ${formatFullDate(state.saved.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: kPrimary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─── Fields ───────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
        letterSpacing: 0.1,
      ),
    );
  }
}

/// Label row with the small edit icon that unlocks (or locks) the field.
class _FieldHeader extends StatelessWidget {
  const _FieldHeader({
    required this.label,
    required this.field,
    required this.isEditing,
  });

  final String label;
  final WordDetailField field;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FieldLabel(label),
        const Spacer(),
        Semantics(
          button: true,
          label: isEditing ? 'Done editing $label' : 'Edit $label',
          child: GestureDetector(
            onTap: () =>
                context.read<WordDetailBloc>().add(FieldEditToggled(field)),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isEditing ? kPrimary : kPrimaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isEditing ? Icons.check_rounded : Icons.edit_outlined,
                size: 15,
                color: isEditing ? Colors.white : kPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditableTextField extends StatelessWidget {
  const _EditableTextField({
    required this.label,
    required this.field,
    required this.controller,
    required this.focusNode,
    required this.isEditing,
    required this.hint,
    required this.minLines,
  });

  final String label;
  final WordDetailField field;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEditing;
  final String hint;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    final isMultiline = minLines > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldHeader(label: label, field: field, isEditing: isEditing),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isEditing ? kSurface : kBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEditing ? kPrimary : kDivider,
              width: isEditing ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: !isEditing,
            minLines: minLines,
            maxLines: isMultiline ? minLines + 4 : 1,
            keyboardType:
                isMultiline ? TextInputType.multiline : TextInputType.text,
            textInputAction:
                isMultiline ? TextInputAction.newline : TextInputAction.done,
            style: const TextStyle(
              fontSize: 14,
              color: kTextPrimary,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: kTextSecondary.withValues(alpha: 0.7),
              ),
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) =>
                context.read<WordDetailBloc>().add(FieldChanged(field, value)),
          ),
        ),
      ],
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({required this.category, required this.isEditing});

  final String category;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    // A word saved under a category that is no longer offered would not match
    // any dropdown item, so fall back to showing it as plain text.
    final canPick = isEditing && kWordCategories.contains(category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldHeader(
          label: 'Category',
          field: WordDetailField.category,
          isEditing: isEditing,
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isEditing ? kSurface : kBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEditing ? kPrimary : kDivider,
              width: isEditing ? 1.5 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: kWordCategories.contains(category) ? category : null,
              hint: Text(
                category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kTextPrimary,
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isEditing
                    ? kTextSecondary
                    : kTextSecondary.withValues(alpha: 0.4),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kTextPrimary,
              ),
              items: [
                for (final value in kWordCategories)
                  DropdownMenuItem<String>(value: value, child: Text(value)),
              ],
              // A null callback locks the dropdown, matching the text fields.
              onChanged: canPick
                  ? (value) {
                      if (value == null) return;
                      context.read<WordDetailBloc>().add(
                            FieldChanged(WordDetailField.category, value),
                          );
                    }
                  : null,
              disabledHint: Text(
                category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kTextPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WordImage extends StatelessWidget {
  const _WordImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(path),
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 160,
          color: kSurface,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_rounded, color: kTextSecondary),
        ),
      ),
    );
  }
}

// ─── Save ─────────────────────────────────────────────────────────────────────
class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.state});

  final WordDetailState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<WordDetailBloc>();
    final canSave = state.hasUnsavedChanges && !state.isSaving;

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: canSave ? () => bloc.add(const WordSaveRequested()) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: kPrimary.withValues(alpha: 0.4),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            child: state.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save changes'),
          ),
        ),
        if (state.hasUnsavedChanges && !state.isSaving) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => bloc.add(const EditsDiscarded()),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Discard changes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
