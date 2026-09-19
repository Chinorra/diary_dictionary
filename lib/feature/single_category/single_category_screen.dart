import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_dictionary/feature/common/color/color.dart';
import 'package:my_dictionary/feature/common/widget/word_card.dart';
import 'package:my_dictionary/feature/home_screen/home_screen.dart';
import 'package:my_dictionary/feature/word_detail/word_detail_screen.dart';

import '../../database/database.dart';
import 'bloc/single_category_bloc.dart';
import 'bloc/single_category_event.dart';
import 'bloc/single_category_state.dart';
import 'repository/single_category_repository.dart';

/// Displays every saved word belonging to one selected category, using the
/// same alphabetical sections, [WordCard] and local search as the All Word
/// screen.
class SingleCategoryScreen extends StatelessWidget {
  const SingleCategoryScreen({
    super.key,
    required this.category,
    this.database,
  });

  final String category;
  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SingleCategoryBloc(
        SingleCategoryRepository(database: database ?? AppDatabase.instance),
        category: category,
      )..add(const CategoryWordsRequested()),
      child: _SingleCategoryView(database: database),
    );
  }
}

class _SingleCategoryView extends StatefulWidget {
  const _SingleCategoryView({this.database});

  final AppDatabase? database;

  @override
  State<_SingleCategoryView> createState() => _SingleCategoryViewState();
}

class _SingleCategoryViewState extends State<_SingleCategoryView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SingleCategoryBloc, SingleCategoryState>(
      listenWhen: (previous, current) =>
          previous.searchQuery != current.searchQuery,
      listener: (context, state) {
        if (_searchController.text != state.searchQuery) {
          _searchController.value = TextEditingValue(
            text: state.searchQuery,
            selection:
                TextSelection.collapsed(offset: state.searchQuery.length),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: kBackground,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: _Body(
              state: state,
              searchController: _searchController,
              database: widget.database,
            ),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.searchController,
    this.database,
  });

  final SingleCategoryState state;
  final TextEditingController searchController;
  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _SingleCategoryAppBar(category: state.category),
        if (state.searchVisible)
          SliverToBoxAdapter(
            child: _SearchField(controller: searchController),
          ),
        if (state.isBusy)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator(color: kPrimary)),
          )
        else if (state.status == SingleCategoryStatus.error)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _ErrorState(message: state.errorMessage),
          )
        else if (state.hasNoSavedWords)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.menu_book_rounded,
              title: 'No words in this category yet',
              subtitle: 'Start adding new words to your diary.',
            ),
          )
        else if (state.hasNoSearchResults)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No matching words found',
              subtitle: 'Try a different search term.',
            ),
          )
        else ...[
          _WordCount(count: state.filteredWords.length),
          ..._sections(state.groupedWords),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  List<Widget> _sections(Map<String, List<Word>> grouped) {
    final slivers = <Widget>[];
    for (final entry in grouped.entries) {
      slivers.add(_LetterHeader(letter: entry.key));
      slivers.add(_WordSection(words: entry.value, database: database));
    }
    return slivers;
  }
}

class _SingleCategoryAppBar extends StatelessWidget {
  const _SingleCategoryAppBar({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final searchVisible = context.select<SingleCategoryBloc, bool>(
      (bloc) => bloc.state.searchVisible,
    );

    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      backgroundColor: kSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: kSurface,
      iconTheme: const IconThemeData(color: kTextPrimary),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category',
              style: TextStyle(
                color: kTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        background: const DecoratedBox(
          decoration: BoxDecoration(
            color: kSurface,
            border: Border(bottom: BorderSide(color: kDivider)),
          ),
          child: SizedBox.expand(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 8),
          child: IconButton(
            tooltip: searchVisible ? 'Close search' : 'Search words',
            icon: Icon(
              searchVisible ? Icons.close_rounded : Icons.search_rounded,
              color: kTextPrimary,
              size: 22,
            ),
            onPressed: () => context
                .read<SingleCategoryBloc>()
                .add(const CategorySearchToggled()),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        height: 48,
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
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontSize: 15,
            color: kTextPrimary,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: 'Search in this category...',
            hintStyle: TextStyle(
              fontSize: 15,
              color: kTextSecondary.withValues(alpha: 0.7),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: kTextSecondary,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (value) => context
              .read<SingleCategoryBloc>()
              .add(CategorySearchQueryChanged(value)),
        ),
      ),
    );
  }
}

class _WordCount extends StatelessWidget {
  const _WordCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Text(
          count == 1 ? '1 word' : '$count words',
          style: const TextStyle(
            fontSize: 13,
            color: kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _LetterHeader extends StatelessWidget {
  const _LetterHeader({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Divider(height: 1, color: kDivider)),
          ],
        ),
      ),
    );
  }
}

class _WordSection extends StatelessWidget {
  const _WordSection({required this.words, this.database});

  final List<Word> words;
  final AppDatabase? database;

  Future<void> _openDetail(BuildContext context, Word word) async {
    final bloc = context.read<SingleCategoryBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WordDetailScreen(word: word, database: database),
      ),
    );
    // The word may have been edited, or moved to another category.
    bloc.add(const CategoryWordsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          final word = words[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: WordCard(
              key: ValueKey(word.id),
              word: TodayWord(
                word: word.word,
                partOfSpeech: word.partOfSpeech,
                definition: word.definition,
              ),
              onTap: () => _openDetail(context, word),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: kTextSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: kTextSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
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
              message ?? 'Unable to load words in this category.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<SingleCategoryBloc>()
                  .add(const CategoryWordsRequested()),
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
