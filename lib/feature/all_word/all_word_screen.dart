// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_dictionary/feature/add_word/add_word_screen.dart';

// ─── Design Tokens (from Stitch "All Words" project) ───────────────────────
const _kPrimary = Color(0xFF4C99E6);
const _kPrimaryLight = Color(0xFFE8F3FD);
const _kBackground = Color(0xFFF5F7FA);
const _kSurface = Colors.white;
const _kTextPrimary = Color(0xFF1A2332);
const _kTextSecondary = Color(0xFF6B7A8D);
const _kDivider = Color(0xFFEDF0F4);

// ─── Sample Data ─────────────────────────────────────────────────────────────
class WordEntry {
  final String word;
  final String partOfSpeech;
  final String definition;

  const WordEntry({
    required this.word,
    required this.partOfSpeech,
    required this.definition,
  });
}

const _kWords = <WordEntry>[
  WordEntry(word: 'Abundance', partOfSpeech: 'noun', definition: 'A very large quantity of something.'),
  WordEntry(word: 'Altruism', partOfSpeech: 'noun', definition: 'Disinterested and selfless concern for the well-being of others.'),
  WordEntry(word: 'Ambivalence', partOfSpeech: 'noun', definition: 'Having mixed feelings or contradictory ideas about something.')
];

// ─── Main Screen ─────────────────────────────────────────────────────────────
class AllWordScreen extends StatefulWidget {
  const AllWordScreen({super.key});

  @override
  _AllWordScreenState createState() => _AllWordScreenState();
}

class _AllWordScreenState extends State<AllWordScreen>
    with TickerProviderStateMixin {
  int _selectedNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<WordEntry> get _filteredWords {
    if (_searchQuery.isEmpty) return _kWords;
    return _kWords
        .where((w) =>
            w.word.toLowerCase().contains(_searchQuery) ||
            w.definition.toLowerCase().contains(_searchQuery))
        .toList();
  }

  Map<String, List<WordEntry>> get _groupedWords {
    final map = <String, List<WordEntry>>{};
    for (final word in _filteredWords) {
      final letter = word.word[0].toUpperCase();
      map.putIfAbsent(letter, () => []).add(word);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  void _navigateToAddWord() {
    Navigator.of(context).push(
       MaterialPageRoute<void>(
      builder: (BuildContext context) => const AddWordPage(),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: (i) => setState(() => _selectedNavIndex = i),
      ),
      floatingActionButton: _AddWordFAB(onPressed: _navigateToAddWord),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        _buildSearchBar(),
        _buildWordCount(),
        if (_groupedWords.isEmpty)
          _buildEmptyState()
        else
          ..._buildWordGroups(),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 110,
      floating: false,
      pinned: true,
      backgroundColor: _kSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: _kSurface,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vocabulary Diary',
              style: TextStyle(
                color: _kTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'All Words',
              style: TextStyle(
                color: _kTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            color: _kSurface,
            border: Border(
              bottom: BorderSide(color: _kDivider, width: 1),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: _AvatarButton(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
              fontSize: 15,
              color: _kTextPrimary,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: 'Search words...',
              hintStyle: TextStyle(
                fontSize: 15,
                color: _kTextSecondary.withValues(alpha: 0.7),
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: _kTextSecondary, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: _kTextSecondary, size: 18),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordCount() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: Text(
          '${_filteredWords.length} words',
          style: const TextStyle(
            fontSize: 13,
            color: _kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: _kTextSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'No words found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _kTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: 14,
                color: _kTextSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWordGroups() {
    final groups = _groupedWords;
    final result = <Widget>[];
    for (final entry in groups.entries) {
      result.add(_buildLetterHeader(entry.key));
      result.add(_buildWordList(entry.value));
    }
    return result;
  }

  Widget _buildLetterHeader(String letter) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _kPrimary,
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
            Expanded(
              child: Container(height: 1, color: _kDivider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordList(List<WordEntry> words) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _WordCard(word: words[index], index: index),
          childCount: words.length,
        ),
      ),
    );
  }
}

// ─── Word Card ──────────────────────────────────────────────────────────────
class _WordCard extends StatefulWidget {
  final WordEntry word;
  final int index;

  const _WordCard({required this.word, required this.index});

  @override
  State<_WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<_WordCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTap: () {
          // TODO: Navigate to word detail
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _isPressed
                      ? _kPrimary.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: _isPressed ? 12 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.word.word,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _kTextPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _kPrimaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.word.partOfSpeech,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _kPrimary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.word.definition,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _kTextSecondary,
                            height: 1.45,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _kTextSecondary.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Navigation Bar ───────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  static const _items = [
    (icon: Icons.format_list_bulleted_rounded, label: 'All Words'),
    (icon: Icons.folder_outlined, label: 'Categories'),
    (icon: Icons.school_outlined, label: 'Practice'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kDivider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isSelected = i == selectedIndex;
              return Expanded(
                child: _NavItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isSelected ? _kPrimaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: widget.isSelected ? _kPrimary : _kTextSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                color: widget.isSelected ? _kPrimary : _kTextSecondary,
              ),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar Button ───────────────────────────────────────────────────────────
class _AvatarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4C99E6), Color(0xFF2E7BCE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text(
          'V',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── FAB ─────────────────────────────────────────────────────────────────────
class _AddWordFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddWordFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }
}
