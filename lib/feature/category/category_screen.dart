import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_dictionary/feature/common/color/color.dart';
import 'package:my_dictionary/feature/common/widget/category_card.dart';

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
        child: BlocBuilder<CategoryBloc, CategoryState>(
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
