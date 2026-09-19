// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_dictionary/feature/add_word/add_word_screen.dart';
import 'package:my_dictionary/feature/all_word/all_word_screen.dart';
import 'package:my_dictionary/feature/category/category_screen.dart';
import 'package:my_dictionary/feature/common/color/color.dart';
import 'package:my_dictionary/feature/common/diary_date.dart';
import 'package:my_dictionary/feature/common/widget/word_card.dart';
import 'package:my_dictionary/feature/word_detail/word_detail_screen.dart';

import '../../database/database.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';
import 'repository/home_repository.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────


// ─── Today's Word Model ───────────────────────────────────────────────────────
class TodayWord {
  final String word;
  final String definition;
  final String partOfSpeech;

  const TodayWord({
    required this.word,
    required this.definition,
    required this.partOfSpeech,
  });
}

// ─── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.database});

  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
        HomeRepository(database: database ?? AppDatabase.instance),
      )..add(const DiaryDayRequested()),
      child: _HomeView(database: database),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView({this.database});

  final AppDatabase? database;

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> with TickerProviderStateMixin {
  int _activeCarouselDot = 1;

  late final AnimationController _enterController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOut));
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  /// Loads [date], or reloads the day currently on screen when omitted, so
  /// words saved on another screen show up here.
  void _loadDiaryDay([DateTime? date]) {
    if (!mounted) return;
    final bloc = context.read<HomeBloc>();
    bloc.add(DiaryDayRequested(date ?? bloc.state.date));
  }

  Future<void> _navigateToAddWord() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            AddWordPage(database: widget.database),
      ),
    );
    // A saved word is always stamped with the current time, so come back to
    // today's page to make sure the new word is visible.
    _loadDiaryDay(DateTime.now());
  }

  Future<void> _navigateToAllWords() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AllWordScreen(database: widget.database),
      ),
    );
    _loadDiaryDay();
  }

  Future<void> _navigateToCategories() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryScreen(database: widget.database),
      ),
    );
    _loadDiaryDay();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: kBackground,
          body: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(state),
                    _buildCarouselDots(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildSectionTitle("Today's Words"),
                            const SizedBox(height: 12),
                            _buildWords(state),
                            const SizedBox(height: 8),
                            _buildProgressBox(state),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Streak'),
                            const SizedBox(height: 12),
                            _buildStreakCard(),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _MinimalBottomNav(
            onAllWordsTap: _navigateToAllWords,
            onCategoriesTap: _navigateToCategories,
            onAddTap: _navigateToAddWord,
          ),
        );
      },
    );
  }

  /// Words saved on the selected diary day, with their loading/error/empty
  /// states.
  Widget _buildWords(HomeState state) {
    if (state.isBusy) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    if (state.status == HomeStatus.error) {
      return _HomeMessageBox(
        icon: Icons.cloud_off_rounded,
        title: state.errorMessage ?? 'Something went wrong.',
        subtitle: 'Pull the page back up by trying again.',
        actionLabel: 'Try again',
        onAction: _loadDiaryDay,
      );
    }

    if (state.hasNoWords) {
      return _HomeMessageBox(
        icon: Icons.menu_book_rounded,
        title: 'No words yet',
        subtitle: 'Add your first word of the day to start this page.',
        actionLabel: 'Add a word',
        onAction: _navigateToAddWord,
      );
    }

    return Column(
      children: [
        for (final word in state.words)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WordCard(
              key: ValueKey(word.id),
              word: TodayWord(
                word: word.word,
                partOfSpeech: word.partOfSpeech,
                definition: word.definition,
              ),
              onTap: () => _navigateToWordDetail(word),
            ),
          ),
      ],
    );
  }

  Future<void> _navigateToWordDetail(Word word) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WordDetailScreen(word: word, database: widget.database),
      ),
    );
    // The word may have been edited, so show the stored values again.
    _loadDiaryDay();
  }

  Widget _buildHeader(HomeState state) {
    final now = state.date ?? DateTime.now();
    final label = formatShortDate(now);
    final dateStr =
        isSameDiaryDay(now, DateTime.now()) ? 'Today — $label' : label;

    return Container(
      color: kSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Hamburger menu
          _HeaderIconButton(
            icon: Icons.menu_rounded,
            onTap: () {},
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'VOCABULARY DIARY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // Calendar icon
          _HeaderIconButton(
            icon: Icons.calendar_today_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselDots() {
    return Container(
      color: kSurface,
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          final isActive = i == _activeCarouselDot;
          return GestureDetector(
            onTap: () => setState(() => _activeCarouselDot = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive ? kPrimary : kDivider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildProgressBox(HomeState state) {
    final count = state.words.length;
    final progressText = count == 0
        ? 'No words saved today yet — add your first one!'
        : "You've learned $count new ${count == 1 ? 'word' : 'words'} today!";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kPrimary.withValues(alpha: 0.2),
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            progressText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: kTextSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: const Text(
              "Review yesterday's list →",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C99E6), Color(0xFF2E7BCE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔥 7-day streak!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep it up — come back tomorrow.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildMiniStreak(),
        ],
      ),
    );
  }

  Widget _buildMiniStreak() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final done = [true, true, true, true, true, true, true];
    return Row(
      children: List.generate(7, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: done[i] ? Colors.white : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: done[i] ? const Icon(Icons.check_rounded, size: 12, color: kPrimary) : null,
              ),
              const SizedBox(height: 4),
              Text(
                days[i],
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Home Message Box ─────────────────────────────────────────────────────────
/// Card used for the empty and error states of the diary page.
class _HomeMessageBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _HomeMessageBox({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: kTextSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: kTextSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onAction,
            child: Text(
              '$actionLabel →',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header Icon Button ───────────────────────────────────────────────────────
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: kTextPrimary, size: 20),
      ),
    );
  }
}

// ─── Today Word Card ──────────────────────────────────────────────────────────


// ─── Minimal Bottom Nav ───────────────────────────────────────────────────────
class _MinimalBottomNav extends StatelessWidget {
  final VoidCallback onAllWordsTap;
  final VoidCallback onCategoriesTap;
  final VoidCallback onAddTap;

  const _MinimalBottomNav({
    required this.onAllWordsTap,
    required this.onCategoriesTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kDivider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  // All Words tab
                  Expanded(
                    child: GestureDetector(
                      onTap: onAllWordsTap,
                      behavior: HitTestBehavior.opaque,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.all_inclusive_rounded, color: kPrimary, size: 22),
                          SizedBox(height: 3),
                          Text(
                            'ALL WORDS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: kPrimary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Spacer for FAB
                  const SizedBox(width: 72),
                  // Categories tab
                  Expanded(
                    child: GestureDetector(
                      onTap: onCategoriesTap,
                      behavior: HitTestBehavior.opaque,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined, color: kTextSecondary, size: 22),
                          SizedBox(height: 3),
                          Text(
                            'CATEGORIES',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: kTextSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Central FAB
              Positioned(
                top: 0,
                child: GestureDetector(
                  onTap: onAddTap,
                  child: Transform.translate(
                    offset: const Offset(0, -16),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
