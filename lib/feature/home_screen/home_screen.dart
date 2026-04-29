// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_dictionary/feature/add_word/add_word_page.dart';
import 'package:my_dictionary/feature/all_word/all_word_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF4C99E6);
const _kPrimaryLight = Color(0xFFE8F3FD);
const _kBackground = Color(0xFFF5F7FA);
const _kSurface = Colors.white;
const _kTextPrimary = Color(0xFF1A2332);
const _kTextSecondary = Color(0xFF6B7A8D);
const _kDivider = Color(0xFFEDF0F4);

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

const _kTodayWords = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
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
                        ..._kTodayWords.map(
                          (word) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TodayWordCard(word: word),
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
        onAddTap: _navigateToAddWord,
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateStr = 'Today — ${monthNames[now.month - 1]} ${now.day}';

    return Container(
      color: _kSurface,
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
                    color: _kTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'VOCABULARY DIARY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _kPrimary,
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
      color: _kSurface,
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
                color: isActive ? _kPrimary : _kDivider,
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
        color: _kTextPrimary,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildProgressBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: _kPrimaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _kPrimary.withValues(alpha: 0.2),
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
              color: _kPrimary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withValues(alpha: 0.3),
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
              color: _kTextSecondary,
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
                color: _kPrimary,
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
            color: _kPrimary.withValues(alpha: 0.3),
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
                  color: done[i]
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: done[i]
                    ? const Icon(Icons.check_rounded, size: 12, color: _kPrimary)
                    : null,
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
          color: _kBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _kTextPrimary, size: 20),
      ),
    );
  }
}

// ─── Today Word Card ──────────────────────────────────────────────────────────
class _TodayWordCard extends StatefulWidget {
  final TodayWord word;

  const _TodayWordCard({required this.word});

  @override
  State<_TodayWordCard> createState() => _TodayWordCardState();
}

class _TodayWordCardState extends State<_TodayWordCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _pressController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pressController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _pressController.reverse();
      },
      onTap: () {},
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? _kPrimary.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _isPressed ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Blue book icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _kPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.word.word,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _kPrimaryLight,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.word.partOfSpeech,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _kPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.word.definition,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _kTextSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _kBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.volume_up_rounded,
                          color: _kTextSecondary, size: 16),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _kTextSecondary.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Minimal Bottom Nav ───────────────────────────────────────────────────────
class _MinimalBottomNav extends StatelessWidget {
  final VoidCallback onAllWordsTap;
  final VoidCallback onAddTap;

  const _MinimalBottomNav({
    required this.onAllWordsTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kDivider, width: 1)),
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
                          Icon(Icons.all_inclusive_rounded,
                              color: _kPrimary, size: 22),
                          SizedBox(height: 3),
                          Text(
                            'ALL WORDS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary,
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
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined,
                              color: _kTextSecondary, size: 22),
                          SizedBox(height: 3),
                          Text(
                            'CATEGORIES',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _kTextSecondary,
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
                        color: _kPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kPrimary.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 28),
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
