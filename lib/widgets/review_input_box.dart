import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'star_rating_bar.dart';
import 'dart:convert';

class ReviewInputBox extends StatefulWidget {
  final int partyId;
  final int movieId;
  final VoidCallback onReviewSubmitted;

  const ReviewInputBox({
    super.key,
    required this.partyId,
    required this.movieId,
    required this.onReviewSubmitted,
  });

  @override
  State<ReviewInputBox> createState() => _ReviewInputBoxState();
}

class _ReviewInputBoxState extends State<ReviewInputBox> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;
  bool _isExpanded = false;
  double _rating = 0.0;

  String? nickname;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final token = await const FlutterSecureStorage().read(key: 'access_token');
      final dio = Dio();
      final res = await dio.get(
        'http://10.0.2.2:8000/api/me',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      setState(() {
        nickname = res.data['nickname'];
        profileImageUrl = res.data['profile_image'];
      });
    } catch (e) {
      print('유저 정보 불러오기 실패: $e');
    }
  }

  Future<void> _submitReview() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _rating == 0) return;

    setState(() => _isSubmitting = true);

    try {
      final token = await const FlutterSecureStorage().read(key: 'access_token');
      final dio = Dio();

      await dio.post(
        'http://10.0.2.2:8000/api/parties/${widget.partyId}/movies/${widget.movieId}/reviews',
        data: jsonEncode({
          'content': content,
          'rating': _rating,
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      _controller.clear();
      setState(() {
        _rating = 0;
        _isExpanded = false;
      });
      widget.onReviewSubmitted();
    } catch (e) {
      print('리뷰 작성 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 작성에 실패했습니다')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

@override
Widget build(BuildContext context) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F7F9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage('http://10.0.2.2:8000$profileImageUrl')
                  : const AssetImage('assets/default_white.png') as ImageProvider,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isExpanded = true),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEDF2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _controller.text.isEmpty ? 'Write a review...' : _controller.text,
                    style: const TextStyle(fontSize: 14, color: Color.fromARGB(221, 39, 38, 38)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isExpanded) ...[
          const SizedBox(height: 5),
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '리뷰 내용을 입력하세요',
              border: OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              StarRatingBar(
                rating: _rating,
                onRatingChanged: (value) {
                  setState(() => _rating = value);
                },
                iconSize: 34,
              ),
              const Spacer(),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87, 
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _controller.clear();
                            _isExpanded = false;
                            _rating = 0;
                          });
                        },
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE66161), 
                    foregroundColor: Colors.white,        
                  ),
                  onPressed: _isSubmitting ? null : _submitReview,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('등록'),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
}
