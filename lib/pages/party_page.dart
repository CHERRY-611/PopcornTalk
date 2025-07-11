import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/section_title.dart';
import '../widgets/horizontal_card_list.dart';
import '../widgets/review_list.dart';
import '../widgets/review_input_box.dart';
import '../widgets/movie_card.dart';
import '../widgets/splash_overlay.dart';
import 'movie_search_page.dart';

class PartyPage extends StatefulWidget {
  final dynamic party;

  const PartyPage({Key? key, required this.party}) : super(key: key);

  @override
  State<PartyPage> createState() => _PartyPageState();
}

class _PartyPageState extends State<PartyPage> {
  List<dynamic> partyMovies = [];
  dynamic selectedMovie;
  bool isJoined = false;
  final GlobalKey<ReviewListState> reviewListKey = GlobalKey<ReviewListState>();

  @override
  void initState() {
    super.initState();
    checkJoinedStatus();
    fetchPartyMovies();
  }

  Future<void> fetchPartyMovies() async {
    try {
      final dio = Dio();
      final token = await const FlutterSecureStorage().read(key: 'access_token');
      final response = await dio.get(
        'http://10.0.2.2:8000/api/parties/${widget.party['id']}/movies',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      setState(() {
        partyMovies = response.data;
      });
    } catch (e) {
      print("영화 목록 불러오기 실패: $e");
    }
  }

  Future<void> joinParty() async {
    try {
      final dio = Dio();
      final token = await const FlutterSecureStorage().read(key: 'access_token');

      await dio.post(
        'http://10.0.2.2:8000/api/parties/${widget.party['id']}/join',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("파티에 가입되었습니다!")),
        );
        Navigator.pop(context, true); // 가입 후 이전 페이지로 돌아감
      }
    } catch (e) {
      print("파티 가입 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("파티 가입에 실패했습니다.")),
      );
    }
  }

  Future<void> checkJoinedStatus() async {
    try {
      final dio = Dio();
      final token = await const FlutterSecureStorage().read(key: 'access_token');
      final response = await dio.get(
        'http://10.0.2.2:8000/api/my-parties',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final myParties = response.data as List<dynamic>;
      final alreadyJoined = myParties.any((party) => party['id'] == widget.party['id']);

      setState(() {
        isJoined = alreadyJoined;
      });
    } catch (e) {
      print("내 파티 목록 확인 실패: $e");
    }
  }

  void refreshReviews() {
    reviewListKey.currentState?.fetchReviews();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF9F9F9),
    appBar: AppBar(
      backgroundColor: const Color(0xFFE66161),
      elevation: 0,
      centerTitle: true,
      title: Text(
        widget.party['name'] ?? 'Party',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (!isJoined)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: joinParty,
              child: const Text(
                'Join',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SectionTitle(title: "Popcorn Pick"),
                      if (isJoined)
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Stack(
                                  children: [
                                    MovieSearchPage(partyId: widget.party['id']),
                                    const SplashOverlay(),
                                  ],
                                ),
                              ),
                            );
                            await fetchPartyMovies();
                          }
                        ),
                    ],
                  ),
                ),
                HorizontalCardList(
                  items: partyMovies,
                  imageSize: const Size(127, 176),
                  itemBuilder: (_, movie, size) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMovie = movie;
                      });
                      reviewListKey.currentState?.refresh();
                    },
                    child: MovieCard(movie: movie, imageSize: size),
                  ),
                ),

                // 리뷰 섹션
                if (selectedMovie != null) ...[
                  const SizedBox(height: 8),

                  if (isJoined) ...[
                    ReviewList(
                      key: reviewListKey,
                      partyId: widget.party['id'],
                      movieId: selectedMovie['id'],
                    ),
                   // const SizedBox(height: 60), // 입력창 공간 확보용 패딩
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '🔒 파티에 가입해야 리뷰를 볼 수 있어요.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]
                ]
              ],
            ),
          ),
        ),

        // 하단 입력창
        if (selectedMovie != null && isJoined)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ReviewInputBox(
                key: ValueKey('input-${selectedMovie['id']}'),
                partyId: widget.party['id'],
                movieId: selectedMovie['id'],
                onReviewSubmitted: () {
                  reviewListKey.currentState?.refresh();
                },
              ),
            ),
          ),
      ],
    ),
  );
}
}
