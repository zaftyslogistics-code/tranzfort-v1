import 'package:flutter/material.dart';
import 'package:transfort_app/core/theme/app_colors.dart';

class BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onToggle;

  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onToggle,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.onToggle,
      icon: Icon(
        widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color:
            widget.isBookmarked ? AppColors.primary : AppColors.textSecondary,
      ),
      tooltip: widget.isBookmarked ? 'Remove bookmark' : 'Bookmark this load',
    );
  }
}
