import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../database/database.dart';
import '../common/color/color.dart';
import 'bloc/add_word_bloc.dart';
import 'bloc/add_word_event.dart';
import 'bloc/add_word_state.dart';
import 'models/word_category.dart';
import 'repository/add_word_repository.dart';

class AddWordPage extends StatelessWidget {
  const AddWordPage({super.key, this.database});

  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddWordBloc(
        AddWordRepository(database: database ?? AppDatabase.instance),
      ),
      child: const _AddWordView(),
    );
  }
}

class _AddWordView extends StatefulWidget {
  const _AddWordView();

  @override
  State<_AddWordView> createState() => _AddWordViewState();
}

class _AddWordViewState extends State<_AddWordView> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _syncControllers(AddWordState state) {
    if (_wordController.text != state.word) {
      _wordController.value = TextEditingValue(
        text: state.word,
        selection: TextSelection.collapsed(offset: state.word.length),
      );
    }
    if (_definitionController.text != state.definition) {
      _definitionController.value = TextEditingValue(
        text: state.definition,
        selection: TextSelection.collapsed(offset: state.definition.length),
      );
    }
    if (_exampleController.text != state.example) {
      _exampleController.value = TextEditingValue(
        text: state.example,
        selection: TextSelection.collapsed(offset: state.example.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddWordBloc, AddWordState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage ||
          previous.validationError != current.validationError,
      listener: (context, state) {
        if (state.status == AddWordStatus.saved) {
          FocusManager.instance.primaryFocus?.unfocus();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Saved to diary')),
            );
          Navigator.of(context).pop();
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
              'Add New Word',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            shape: const Border(bottom: BorderSide(color: kDivider)),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _searchFocus.unfocus();
              context.read<AddWordBloc>().add(const SuggestionsDismissed());
            },
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SearchSection(
                      controller: _wordController,
                      focusNode: _searchFocus,
                      state: state,
                    ),
                    const SizedBox(height: 12),
                    _TranslateButton(isBusy: state.isTranslating),
                    const SizedBox(height: 24),
                    const _FieldLabel('Category'),
                    const SizedBox(height: 8),
                    _CategoryDropdown(category: state.category),
                    const SizedBox(height: 20),
                    const _FieldLabel('Definition'),
                    const SizedBox(height: 8),
                    _MultilineField(
                      controller: _definitionController,
                      hint: 'Enter or edit the definition',
                      minLines: 3,
                      onChanged: (value) => context
                          .read<AddWordBloc>()
                          .add(DefinitionChanged(value)),
                    ),
                    const SizedBox(height: 20),
                    const _FieldLabel('Example sentence'),
                    const SizedBox(height: 8),
                    _MultilineField(
                      controller: _exampleController,
                      hint: 'Enter an example sentence',
                      minLines: 2,
                      onChanged: (value) => context
                          .read<AddWordBloc>()
                          .add(ExampleChanged(value)),
                    ),
                    const SizedBox(height: 20),
                    const _FieldLabel('Image'),
                    const SizedBox(height: 8),
                    _ImagePicker(imagePath: state.imagePath),
                    const SizedBox(height: 28),
                    _SaveButton(isSaving: state.isSaving),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchSection extends StatefulWidget {
  const _SearchSection({
    required this.controller,
    required this.focusNode,
    required this.state,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final AddWordState state;

  @override
  State<_SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<_SearchSection> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();

  @override
  void didUpdateWidget(_SearchSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _syncPortalVisibility());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _syncPortalVisibility());
  }

  void _syncPortalVisibility() {
    if (!mounted) return;
    final shouldShow =
        widget.state.suggestionsVisible && widget.state.suggestions.isNotEmpty;
    if (shouldShow && !_portal.isShowing) {
      _portal.show();
    } else if (!shouldShow && _portal.isShowing) {
      _portal.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AddWordBloc>();

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (_) => _SuggestionsOverlay(
          link: _link,
          suggestions: widget.state.suggestions,
          onSelect: (value) {
            widget.focusNode.unfocus();
            bloc.add(SuggestionSelected(value));
          },
        ),
        child: Container(
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            textInputAction: TextInputAction.search,
            style: const TextStyle(
              fontSize: 15,
              color: kTextPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Search word...',
              hintStyle: TextStyle(
                fontSize: 15,
                color: kTextSecondary.withValues(alpha: 0.7),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: kTextSecondary,
                size: 20,
              ),
              suffixIcon: widget.state.word.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: kTextSecondary,
                        size: 18,
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        bloc.add(const WordQueryChanged(''));
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (value) => bloc.add(WordQueryChanged(value)),
            onSubmitted: (_) => bloc.add(const SuggestionsDismissed()),
          ),
        ),
      ),
    );
  }
}

class _SuggestionsOverlay extends StatelessWidget {
  const _SuggestionsOverlay({
    required this.link,
    required this.suggestions,
    required this.onSelect,
  });

  final LayerLink link;
  final List<String> suggestions;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final leaderSize = link.leaderSize ?? Size.zero;
    return Positioned(
      left: 0,
      top: 0,
      width: leaderSize.width == 0 ? null : leaderSize.width,
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(0, 6),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kDivider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < suggestions.length; i++) ...[
                    if (i != 0) const Divider(height: 1, color: kDivider),
                    InkWell(
                      onTap: () => onSelect(suggestions[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.north_east_rounded,
                              size: 16,
                              color: kTextSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              suggestions[i],
                              style: const TextStyle(
                                fontSize: 14,
                                color: kTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TranslateButton extends StatelessWidget {
  const _TranslateButton({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 36,
        child: ElevatedButton(
          onPressed: isBusy
              ? null
              : () =>
                  context.read<AddWordBloc>().add(const TranslateRequested()),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: kPrimary.withValues(alpha: 0.5),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          child: isBusy
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Translate'),
        ),
      ),
    );
  }
}

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

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: category,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: kTextSecondary),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextPrimary,
          ),
          items: [
            for (final value in kWordCategories)
              DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
          ],
          onChanged: (value) {
            if (value == null) return;
            context.read<AddWordBloc>().add(CategoryChanged(value));
          },
        ),
      ),
    );
  }
}

class _MultilineField extends StatelessWidget {
  const _MultilineField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.minLines = 2,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider),
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines + 4,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
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
        onChanged: onChanged,
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AddWordBloc>();
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider),
      ),
      child: hasImage
          ? Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(imagePath!),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: kBackground,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_rounded,
                        color: kTextSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showImagePickerHint(context),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: const Text('Replace'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimary,
                          side: const BorderSide(color: kPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => bloc.add(const ImageRemoved()),
                        icon:
                            const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kTextSecondary,
                          side: const BorderSide(color: kDivider),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _showImagePickerHint(context),
              child: Container(
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: kDivider,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: kTextSecondary),
                    SizedBox(width: 8),
                    Text(
                      '+ Add Image',
                      style: TextStyle(
                        color: kTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showImagePickerHint(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text(
          'Image picking requires the image_picker package. '
          'Add it to pubspec.yaml to enable.',
        ),
      ));
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaving});

  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isSaving
            ? null
            : () => context.read<AddWordBloc>().add(const SaveRequested()),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kPrimary.withValues(alpha: 0.6),
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
        child: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Save to diary'),
      ),
    );
  }
}
