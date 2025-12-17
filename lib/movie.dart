class Movie {
  final String id;
  final String title;
  final String? imagePath;
  bool isWatched;
  double rating;

  Movie({
    required this.id,
    required this.title,
    this.imagePath,
    this.isWatched = false,
    this.rating = 0.0,
  });
}
