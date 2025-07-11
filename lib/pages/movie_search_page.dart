import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/section_title.dart';
import '../widgets/horizontal_card_list.dart';
import '../widgets/movie_card_preview.dart';
import '../services/tmdb_service.dart';
import 'dart:convert';

class MovieSearchPage extends StatefulWidget {
  final int partyId;

  const MovieSearchPage({Key? key, required this.partyId}) : super(key: key);

  @override
  State<MovieSearchPage> createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> myParties = [];
  List<dynamic> allParties = [];

  List<dynamic> trending = [];
  List<dynamic> topRated = [];
  List<dynamic> nowPlaying = [];
  List<dynamic> korean = [];
  List<dynamic> action = [];
  List<dynamic> comedy = [];
  List<dynamic> sciFi = [];
  List<dynamic> horror = [];
  List<dynamic> animation = [];

  // 검색용 List
  List<dynamic> _allMovieList = [];
  List<dynamic> _filteredMovieList = [];

  bool isLoading = true;
  bool hasError = false;

  String? profileImageUrl;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  void _filterMovies(String query) {
    final lowerQuery = query.toLowerCase();

    final filtered = _allMovieList.where((movie) {
      final title = (movie['title'] ?? '').toString().toLowerCase();
      return title.contains(lowerQuery);
    }).toList();

    setState(() {
      _searchQuery = query;
      _filteredMovieList = filtered;
    });
  }

  Future<void> addMovieToParty(Map<String, dynamic> movie) async {
  try {
    final dio = Dio();
    final token = await const FlutterSecureStorage().read(key: 'access_token');

    await dio.post(
      'http://10.0.2.2:8000/api/parties/${widget.partyId}/movies',
      data: jsonEncode({
        'tmdb_id': movie['id'],
        'title': movie['title'],
        'poster_path': movie['poster_path'],
      }),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (context.mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    print('영화 추가 실패: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("영화를 추가하는 데 실패했습니다.")),
    );
  }
}
  Future<void> fetchMovies() async {
    try {
      final results = await Future.wait([
        TMDBService.fetchTrending(),
        TMDBService.fetchTopRated(),
        TMDBService.fetchNowPlaying(),
        TMDBService.fetchKoreanMovies(),
        TMDBService.fetchByGenre(28),
        TMDBService.fetchByGenre(35),
        TMDBService.fetchByGenre(878),
        TMDBService.fetchByGenre(27),
        TMDBService.fetchByGenre(16),
      ]);

      final combined = [
        ...results[0],
        ...results[1],
        ...results[2],
        ...results[3],
        ...results[4],
        ...results[5],
        ...results[6],
        ...results[7],
        ...results[8],
      ];

      // 영화 ID 기준으로 중복 제거
      final uniqueMovies = {
        for (var movie in combined) movie['id']: movie
      }.values.toList();

      setState(() {
        trending = results[0].take(10).toList();
        topRated = results[1].take(10).toList();
        nowPlaying = results[2].take(10).toList();
        korean = results[3].take(10).toList();
        action = results[4].take(10).toList();
        comedy = results[5].take(10).toList();
        sciFi = results[6].take(10).toList();
        horror = results[7].take(10).toList();
        animation = results[8].take(10).toList();

        _allMovieList = uniqueMovies;
        _filteredMovieList = uniqueMovies;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }


  Widget buildMovieSection(String title, List<dynamic> movies) {
    if (movies.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title),
        HorizontalCardList(
          items: movies,
          imageSize: const Size(127, 176),
          itemBuilder: (context, movie, size) => Stack(
            children: [
              MovieCardPreview(movie: movie, imageSize: size),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => addMovieToParty(movie),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(child: Text('영화 정보를 불러오는 데 실패했습니다.'))
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        title: const Text(
                          'Popcorns',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: const Color(0xFFE66161),
                        floating: true,
                        snap: true,
                        centerTitle: true,
                        elevation: 1,
                      ),

                      // 아래 내용들 삽입
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: '영화 제목을 검색하세요',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            _filterMovies('');
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: _filterMovies,
                              ),
                            ),

                            if (_searchQuery.isNotEmpty) ...[
                              Padding( padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8)),
                              HorizontalCardList(
                                items: _filteredMovieList,
                                imageSize: const Size(127, 176),
                                itemBuilder: (context, movie, size) => Stack(
                                  children: [
                                    MovieCardPreview(movie: movie, imageSize: size),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => addMovieToParty(movie),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[

                              buildMovieSection('Trending Now', trending),
                              buildMovieSection('Top Rated Movies', topRated),
                              buildMovieSection('Action Movies', action),
                              buildMovieSection('Comedy Movies', comedy),
                              buildMovieSection('SF Movies', sciFi),
                              buildMovieSection('Horror Movies', horror),
                              buildMovieSection('Animation Movies', animation),

                              const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
