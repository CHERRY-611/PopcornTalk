import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String nickname;
  final String content;
  final String createdAt;
  final double rating;
  final String? profileImageUrl;

  const ReviewCard({
    Key? key,
    required this.nickname,
    required this.content,
    required this.createdAt,
    required this.rating,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? NetworkImage(profileImageUrl!)
                : const AssetImage('assets/default_white.png') as ImageProvider,
          ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              nickname,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: List.generate(5, (index) {
              if (index + 1 <= rating) {
                return const Icon(Icons.star, size: 17, color: Colors.amber);
              } else if (index + 0.5 <= rating) {
                return const Icon(Icons.star_half, size: 17, color: Colors.amber);
              } else {
                return const Icon(Icons.star_border, size: 17, color: Colors.amber);
              }
            }),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            createdAt,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
