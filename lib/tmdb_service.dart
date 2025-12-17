import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TMDBService {
  static const String apiKey = '161a12c524b12be380a1fad09f93f9f1';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  static Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final url = Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query');
    debugPrint('Searching movies with URL: $url');
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl$path';
  }
}
