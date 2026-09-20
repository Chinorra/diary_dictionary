import 'package:flutter/material.dart';
import 'package:my_dictionary/feature/common/color/color.dart';

/// Rounded, primary-coloured button for the main action of a screen.
///
/// Shared so every screen's main action keeps the same shape, colour and
/// shadow.
class PrimaryFab extends StatelessWidget {
  const PrimaryFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.tooltip,
  });

  /// Null disables the button, for example while its action is running.
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        tooltip: tooltip,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 26),
      ),
    );
  }
}
