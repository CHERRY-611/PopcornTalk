import 'package:flutter/material.dart';
import '../pages/party_page.dart';

class PartyCard extends StatelessWidget {
  final Map<String, dynamic> party;
  final Size imageSize;
  final VoidCallback? onTap;

  const PartyCard({
    super.key,
    required this.party,
    required this.imageSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseUrl = 'http://10.0.2.2:8000';
    final imagePath = party['image_url'];
    final hasImage = imagePath != null && imagePath.toString().isNotEmpty;
    final imageUrl = hasImage ? '$baseUrl$imagePath' : null;
    final partyName = party['name'] ?? '이름 없음';

    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PartyPage(party: party),
              ),
            );
          },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: imageSize.width,
                    height: imageSize.height,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: imageSize.width,
                      height: imageSize.height,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  )
                : Container(
                    width: imageSize.width,
                    height: imageSize.height,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: imageSize.width,
            child: Text(
              partyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
