import 'package:flutter/material.dart';
import '../widgets/section_title.dart';
import '../widgets/horizontal_card_list.dart';
import '../widgets/horizontal_party_card_list.dart';
import '../widgets/movie_card_preview.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/party_card.dart';
import '../services/tmdb_service.dart';
import 'create_party_page.dart';
import 'party_page.dart';
import 'profile_edit_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String nickname;
  String? profileImageUrl;

  HomePage({
    Key? key,
    required this.username,
    required this.nickname,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  List<dynamic> upcoming = [];

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
    fetchParties();
    profileImageUrl = widget.profileImageUrl;
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

  Future<void> fetchParties() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');
  final dio = Dio();

  try {
    final myResponse = await dio.get(
      'http://10.0.2.2:8000/api/my-parties',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    final allResponse = await dio.get(
      'http://10.0.2.2:8000/api/parties',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    setState(() {
      myParties = myResponse.data;
      allParties = allResponse.data;
    });
  } catch (e) {
    print("파티 불러오기 실패: $e");
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
        TMDBService.fetchUpcoming(),
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
        ...results[9],
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
        upcoming = results[9].take(10).toList();

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
          itemBuilder: (context, movie, size) => MovieCardPreview(
            movie: movie,
            imageSize: size,
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
                          'PopcornTalk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20
                          ),
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () async {
                                final updatedProfileUrl = await  Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ProfileEditPage()),
                                );
                                if (updatedProfileUrl != null) {
                                  setState(() {
                                    profileImageUrl = updatedProfileUrl;
                                  });
                                }
                              },
                              child: CircleAvatar(
                                radius: 16,
                                backgroundImage: profileImageUrl != null
                                  ? NetworkImage('http://10.0.2.2:8000${profileImageUrl!}')
                                  : const AssetImage('assets/default_white.png') as ImageProvider,
                              )
                            ),
                          ),
                        ],
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
                                  fillColor: const Color.fromARGB(255, 228, 228, 228),
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
                                itemBuilder: (context, movie, size) => MovieCardPreview(
                                  movie: movie,
                                  imageSize: size,
                                ),
                              ),
                            ] else ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: SectionTitle(title: '공개 예정작'),
                              ),
                            // const SizedBox(height: 5),
                              SizedBox(
                                height: 165,  
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: upcoming.length > 3 ? 3 : upcoming.length,
                                  itemBuilder: (context, index) {
                                    final movie = upcoming[index];
                                    final imageUrl = movie['backdrop_path'] != null
                                        ? 'https://image.tmdb.org/t/p/w500${movie['backdrop_path']}'
                                        : 'https://placehold.co/357x171?text=No+Image';

                                    return Padding(
                                      padding: const EdgeInsets.only(left: 16, right: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              imageUrl,
                                              width: 300,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),

                              buildMovieSection('지금 인기 있는 콘텐츠', trending),
                              buildMovieSection('관객이 선택한 영화', topRated),
                              buildMovieSection('심장이 쫄깃한 액션', action),
                              buildMovieSection('웃음 보장! 코미디 영화', comedy),
                              buildMovieSection('상상 그 이상의 SF', sciFi),
                              buildMovieSection('오싹오싹 공포 영화', horror),
                              buildMovieSection('애니메이션 영화', animation),

                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                    child: SectionTitle(title: 'My Popcorn'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const CreatePartyPage()),
                                      );

                                      if (result == true) {
                                        await fetchParties();
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              ),
                            if (myParties.isNotEmpty)
                              HorizontalPartyCardList(
                                items: myParties,
                                imageSize: const Size(151, 202),
                                itemBuilder: (_, party, size) => PartyCard(
                                  party: party,
                                  imageSize: size,
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => PartyPage(party: party)),
                                    );
                                    if (result == true) {
                                      await fetchParties();
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: SectionTitle(title: 'Popcorn List'),
                            ),

                            if (allParties.isNotEmpty)
                              HorizontalPartyCardList(
                                items: allParties,
                                imageSize: const Size(151, 202),
                                itemBuilder: (_, party, size) => PartyCard(
                                  party: party,
                                  imageSize: size,
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => PartyPage(party: party)),
                                    );
                                    if (result == true) {
                                      await fetchParties();
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}