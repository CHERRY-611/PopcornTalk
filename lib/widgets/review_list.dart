import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'review_card.dart';

class ReviewList extends StatefulWidget {
  final int partyId;
  final int movieId;

  const ReviewList({
    Key? key,
    required this.partyId,
    required this.movieId,
  }) : super(key: key);

  @override
  State<ReviewList> createState() => ReviewListState();
}

class ReviewListState extends State<ReviewList> {
  List<dynamic> reviews = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  @override
  void didUpdateWidget(covariant ReviewList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movieId != widget.movieId) {
      fetchReviews(); // 리뷰 갱신
    }
  }

  Future<void> refresh() async {
    await fetchReviews();
    setState(() {}); 
  }

  Future<void> fetchReviews() async {
    try {
      final token = await const FlutterSecureStorage().read(key: 'access_token');
      final dio = Dio();
      final response = await dio.get(
        'http://10.0.2.2:8000/api/parties/${widget.partyId}/movies/${widget.movieId}/reviews',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      setState(() {
        reviews = response.data;
        isLoading = false;
      });
    } catch (e) {
      print('리뷰 불러오기 실패: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
    children: reviews.map<Widget>((review) {
      final user = review['user'] ?? {};
      final nickname = user['nickname'] ?? '익명';
      final profileImageUrl = user['profile_image'] != null
          ? 'http://10.0.2.2:8000${user['profile_image']}'
          : null;

      return ReviewCard(
        nickname: nickname,
        content: review['content'] ?? '(내용 없음)',
        createdAt: review['created_at'] ?? '',
        rating: (review['rating'] ?? 0).toDouble(),
        profileImageUrl: profileImageUrl,
      );
    }).toList(),
  );
  }
}
