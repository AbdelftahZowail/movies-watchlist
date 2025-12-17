class Movie {
  final String id;
  final String title;
  final String? imagePath;
  final String? imageUrl;
  final String description;
  final double publicRating;
  bool isWatched;
  double rating;

  Movie({
    required this.id,
    required this.title,
    this.imagePath,
    this.imageUrl,
    this.description = '',
    this.publicRating = 0.0,
    this.isWatched = false,
    this.rating = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'description': description,
      'publicRating': publicRating,
      'isWatched': isWatched,
      'rating': rating,
    };
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      imagePath: json['imagePath'] as String?,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String? ?? '',
      publicRating: (json['publicRating'] as num?)?.toDouble() ?? 0.0,
      isWatched: json['isWatched'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
