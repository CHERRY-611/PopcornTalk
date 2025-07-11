import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';

class MovieCardPreview extends StatefulWidget {
  final dynamic movie;
  final Size imageSize;

  const MovieCardPreview({
    Key? key,
    required this.movie,
    required this.imageSize,
  }) : super(key: key);

  @override
  State<MovieCardPreview> createState() => _MovieCardPreviewState();
}

class _MovieCardPreviewState extends State<MovieCardPreview> {
  bool _showInfo = false;
  String genre = 'Loading...';
  String director = 'Loading...';
  int? runtime;

  // 캐시 저장소 (영화 id 기준)
  static final Map<int, Map<String, dynamic>> _movieCache = {};

  Future<void> fetchMovieDetails() async {
    final id = widget.movie['id'];

    // 캐시 확인
    if (_movieCache.containsKey(id)) {
      final cached = _movieCache[id]!;
      setState(() {
        genre = cached['genre'];
        director = cached['director'];
        runtime = cached['runtime'];
      });
      return;
    }

    // 없으면 API 호출
    try {
      final detail = await TMDBService.fetchMovieDetail(id);
      final directorName = await TMDBService.fetchDirectorName(id);

      final genreNames = (detail['genres'] as List)
          .take(2)
          .map((g) => g['name'])
          .join(', ');

      final data = {
        'genre': genreNames.isNotEmpty ? genreNames : 'Unknown',
        'director': directorName ?? 'Unknown',
        'runtime': detail['runtime'],
      };

      // 캐시에 저장
      _movieCache[id] = data;

      setState(() {
        genre = data['genre'];
        director = data['director'];
        runtime = data['runtime'];
      });
    } catch (e) {
      print('영화 상세 정보 가져오기 실패: $e');
      setState(() {
        director = 'N/A';
        runtime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final imageUrl = 'https://image.tmdb.org/t/p/w500${movie['poster_path']}';
    final title = movie['title'] ?? movie['name'] ?? '';

    return GestureDetector(
      onTap: () async {
        setState(() {
          _showInfo = !_showInfo;
        });

        if (_showInfo) {
          setState(() {
            director = 'Loading...';
            runtime = null;
          });
          await fetchMovieDetails(); // 비동기로 정보 불러오기
        }
      },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: widget.imageSize.width,
                  height: widget.imageSize.height,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          if (_showInfo)
            Positioned(
              top: 0,
              child: Container(
                width: widget.imageSize.width,
                height: widget.imageSize.height,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$title", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    Text("⭐ ${movie['vote_average'].toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    Text("🎬 $director", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    Text("${movie['release_date'] ?? 'Unknown'}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    Text("${runtime != null ? '$runtime min' : 'Loading...'}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
