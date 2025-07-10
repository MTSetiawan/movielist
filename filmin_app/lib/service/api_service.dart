import 'dart:convert';
import 'package:filmin_app/models/comment.dart';
import 'package:filmin_app/models/movie.dart';
import 'package:filmin_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://api_movieapp.test/api';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'name': name,
        'password': password,
        'password_confirmation': password, // <- WAJIB
      }),
    );
    return json.decode(response.body);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }

  /// GET /movies endpoint
  static Future<List<MovieModel>> fetchMovies(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movies/popular'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((json) => MovieModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  static Future<List<MovieModel>> searchMovies(
      String query, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search-movies?query=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body)['results'];
      return results.map((json) => MovieModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }

  static Future<void> postComment(
      int movieId, String content, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/movies/$movieId/comments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post comment');
    }
  }

  static Future<List<Comment>> fetchComments(int movieId, String token) async {
    final response = await http
        .get(Uri.parse('$baseUrl/movies/$movieId/comments'), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch comments');
    }
  }

  static Future<UserModel> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  static Future<List<int>> fetchFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$baseUrl/favorites'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<int>();
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  static Future<void> addFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('$baseUrl/favorites/$movieId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 201 && response.statusCode != 409) {
      throw Exception('Failed to add favorite');
    }
  }

  static Future<void> removeFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/$movieId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove favorite');
    }
  }
}
