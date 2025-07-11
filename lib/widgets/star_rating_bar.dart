import 'package:flutter/material.dart';

class StarRatingBar extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final double iconSize;

  const StarRatingBar({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.iconSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final totalWidth = box.size.width;
        final relativeX = localPosition.dx.clamp(0, totalWidth);
        final percent = relativeX / totalWidth;
        final newRating = (percent * 5).clamp(0, 5);
        onRatingChanged((newRating * 2).roundToDouble() / 2);
      },
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final totalWidth = box.size.width;
        final relativeX = localPosition.dx.clamp(0, totalWidth);
        final percent = relativeX / totalWidth;
        final newRating = (percent * 5).clamp(0, 5);
        onRatingChanged((newRating * 2).roundToDouble() / 2);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starValue = index + 1;
          IconData icon;
          if (rating >= starValue) {
            icon = Icons.star;
          } else if (rating >= starValue - 0.5) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }

          return Icon(
            icon,
            size: iconSize,
            color: Colors.amber,
          );
        }),
      ),
    );
  }
}
