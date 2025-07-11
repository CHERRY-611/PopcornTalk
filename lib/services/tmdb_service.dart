import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBService {
  static const String _apiKey = 'Your_Key';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  static Future<List<dynamic>> fetchTrending() async {
    final url = Uri.parse('$_baseUrl/trending/movie/day?api_key=$_apiKey&language=ko-KR');
    return _fetchMovieList(url);
  }

  static Future<List<dynamic>> fetchTopRated() async {
    final url = Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey&language=ko-KR');
    return _fetchMovieList(url);
  }

  static Future<List<dynamic>> fetchNowPlaying() async {
    final url = Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey&language=ko-KR');
    return _fetchMovieList(url);
  }

  static Future<List<dynamic>> fetchUpcoming() async {
    final url = Uri.parse('$_baseUrl/movie/upcoming?api_key=$_apiKey&language=ko-KR');
    return _fetchMovieList(url);
  }

  static Future<List<dynamic>> fetchByGenre(int genreId) async {
    final url = Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=$genreId&language=ko-KR');
    return _fetchMovieList(url);
  }

  static Future<List<dynamic>> _fetchMovieList(Uri url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('TMDB fetch error: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> fetchMovieDetail(int movieId) async {
  final url = Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&language=ko-KR');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load movie detail');
  }
}

  static Future<String?> fetchDirectorName(int movieId) async {
    final url = Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$_apiKey&language=ko-KR');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final crew = data['crew'] as List<dynamic>;
      final director = crew.firstWhere(
        (member) => member['job'] == 'Director',
        orElse: () => null,
      );
      return director?['name'];
    } else {
      throw Exception('Failed to load director info');
    }
  }

  static Future<List<dynamic>> fetchKoreanMovies() async {
    final url = Uri.parse(
      '$_baseUrl/discover/movie'
      '?api_key=$_apiKey'
      '&with_original_language=ko'
      '&sort_by=popularity.desc'
      '&include_adult=false'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load Korean movies');
    }
  }
}