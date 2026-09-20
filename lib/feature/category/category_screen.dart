import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_dictionary/feature/common/color/color.dart';
import 'package:my_dictionary/feature/common/widget/category_card.dart';
import 'package:my_dictionary/feature/common/widget/primary_fab.dart';

import '../../database/database.dart';
import '../single_category/single_category_screen.dart';
import 'bloc/category_bloc.dart';
import 'bloc/category_event.dart';
import 'bloc/category_state.dart';
import 'models/category_summary.dart';
import 'repository/category_repository.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, this.database});

  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryBloc(
        CategoryRepository(database: database ?? AppDatabase.instance),
      )..add(const CategoriesRequested()),
      child: _CategoryView(database: database),
    );
  }
}

class _CategoryView extends StatefulWidget {
  const _CategoryView({this.database});

  final AppDatabase? database;

  @override
  State<_CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<_CategoryView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    final bloc = context.read<CategoryBloc>();
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewCategorySheet(
        existingNames: [
          for (final category in bloc.state.categories) category.name,
        ],
      ),
    );

    if (name == null) return;
    bloc.add(CategoryCreationRequested(name));
  }

  void _openCategory(CategorySummary category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SingleCategoryScreen(
          category: category.name,
          database: widget.database,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: BlocConsumer<CategoryBloc, CategoryState>(
          listenWhen: (previous, current) =>
              current.creationErrorMessage != null &&
              previous.creationErrorMessage != current.creationErrorMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.creationErrorMessage!)),
            );
          },
          builder: (context, state) => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const _CategoryAppBar(),
              if (state.isBusy)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child:
                      Center(child: CircularProgressIndicator(color: kPrimary)),
                )
              else if (state.status == CategoryStatus.error)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(message: state.errorMessage),
                )
              else
                SliverPadding(
                  // Bottom padding keeps the last card clear of the button.
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  sliver: SliverList.builder(
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CategoryCard(
                          key: ValueKey(category.name),
                          category: category,
                          onTap: () => _openCategory(category),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<CategoryBloc, CategoryState>(
        buildWhen: (previous, current) =>
            previous.isCreating != current.isCreating,
        builder: (context, state) => PrimaryFab(
          // Blocked while a category is being stored so one tap makes one
          // category.
          onPressed: state.isCreating ? null : _createCategory,
          tooltip: 'New category',
        ),
      ),
    );
  }
}

class _CategoryAppBar extends StatelessWidget {
  const _CategoryAppBar();

  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(
      pinned: true,
      backgroundColor: kSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: kSurface,
      iconTheme: IconThemeData(color: kTextPrimary),
      titleSpacing: 0,
      title: Text(
        'Categories',
        style: TextStyle(
          color: kTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      shape: Border(bottom: BorderSide(color: kDivider)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: kTextSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Unable to load your categories.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<CategoryBloc>().add(const CategoriesRequested()),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet that asks for the name of a new category.
///
/// Pops with the name once it passes the checks, or with null when the user
/// backs out. [existingNames] is only used to tell the user about a clash
/// straight away; the repository checks the stored categories again before
/// anything is written.
class _NewCategorySheet extends StatefulWidget {
  const _NewCategorySheet({required this.existingNames});

  final List<String> existingNames;

  @override
  State<_NewCategorySheet> createState() => _NewCategorySheetState();
}

class _NewCategorySheetState extends State<_NewCategorySheet> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => sanitizeCategoryName(_controller.text).isNotEmpty;

  void _submit() {
    final name = sanitizeCategoryName(_controller.text);
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter a category name.');
      return;
    }
    if (isDuplicateCategoryName(widget.existingNames, name)) {
      setState(() => _errorMessage = 'That category already exists.');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lifts the sheet above the keyboard while the user types.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'New category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _errorMessage == null ? kDivider : kError,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLength: kMaxCategoryNameLength,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() => _errorMessage = null),
                  onSubmitted: (_) => _submit(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kTextPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Category name',
                    counterText: '',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: kTextSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kError,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: kDivider,
                    disabledForegroundColor: kTextSecondary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
