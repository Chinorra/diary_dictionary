// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_dictionary/feature/add_word/add_word_screen.dart';
import 'package:my_dictionary/feature/all_word/all_word_screen.dart';
import 'package:my_dictionary/feature/category/category_screen.dart';
import 'package:my_dictionary/feature/common/color/color.dart';
import 'package:my_dictionary/feature/common/widget/word_card.dart';

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

const kTodayWords = [
  TodayWord(
    word: 'Ephemeral',
    partOfSpeech: 'adjective',
    definition: 'Lasting for a very short time; fleeting or transitory in nature.',
  ),
  TodayWord(
    word: 'Serendipity',
    partOfSpeech: 'noun',
    definition: 'The occurrence of events by chance in a happy or beneficial way.',
  ),
];

// ─── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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

  void _navigateToAddWord() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const AddWordPage(),
      ),
    );
  }

  void _navigateToAllWords() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AllWordScreen()),
    );
  }

  void _navigateToCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CategoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
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
                        ...kTodayWords.map(
                          (word) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: WordCard(word: word),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildProgressBox(),
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
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr = 'Today — ${monthNames[now.month - 1]} ${now.day}';

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

  Widget _buildProgressBox() {
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
          const Text(
            "You've learned 2 new words today!",
            textAlign: TextAlign.center,
            style: TextStyle(
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
