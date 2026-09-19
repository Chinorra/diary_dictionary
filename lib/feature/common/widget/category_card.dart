import 'package:flutter/material.dart';
import 'package:my_dictionary/feature/category/models/category_summary.dart';
import 'package:my_dictionary/feature/common/color/color.dart';

/// Large tappable card representing one browsable category.
///
/// Shared by every screen that lists categories so the category visual stays
/// consistent across the application.
class CategoryCard extends StatefulWidget {
  final CategorySummary category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
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

  void _setPressed(bool pressed) {
    setState(() => _isPressed = pressed);
    pressed ? _pressController.forward() : _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.category.wordCount;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? kPrimary.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _isPressed ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  categoryIcon(widget.category.name),
                  color: kPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count == 1 ? '1 word' : '$count words',
                      style: const TextStyle(
                        fontSize: 13,
                        color: kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                color: kTextSecondary.withValues(alpha: 0.4),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const Map<String, IconData> _categoryIcons = <String, IconData>{
  'General': Icons.auto_stories_rounded,
  'Food': Icons.restaurant_rounded,
  'Travel': Icons.flight_takeoff_rounded,
  'Work': Icons.work_outline_rounded,
  'Technology': Icons.memory_rounded,
  'People': Icons.people_alt_rounded,
  'Nature': Icons.park_rounded,
  'Other': Icons.more_horiz_rounded,
};

/// Icon used to represent [category], with a neutral fallback so categories
/// outside the canonical list still render correctly.
IconData categoryIcon(String category) =>
    _categoryIcons[category] ?? Icons.label_outline_rounded;
