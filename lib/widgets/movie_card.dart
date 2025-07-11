import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final dynamic movie;
  final Size imageSize;

  const MovieCard({
    Key? key,
    required this.movie,
    required this.imageSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'https://image.tmdb.org/t/p/w500${movie['poster_path']}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: imageSize.width,
            height: imageSize.height,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
