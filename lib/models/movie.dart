class Movie {
  final String id;
  final String title;
  final String synopsis;
  final String genre;
  final int durationMinutes;
  final String posterUrl;
  final String trailerUrl;
  final List<String> showtimeStrings;

  Movie({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.genre,
    required this.durationMinutes,
    required this.posterUrl,
    required this.trailerUrl,
    required this.showtimeStrings,
  });

  factory Movie.fromMap(Map<String, dynamic> data, String documentId) {
    return Movie(
      id: documentId,
      title: data['title'] as String? ?? 'Unknown Title',
      synopsis: data['synopsis'] as String? ?? 'No synopsis available.',
      genre: data['genre'] as String? ?? 'Unknown',
      // Reads the 'duration' field to match your database
      durationMinutes: data['duration'] as int? ?? 0, // Matches 'duration'
      posterUrl: data['posterUrl'] as String? ?? '',
      trailerUrl: data['trailerUrl'] as String? ?? '',
      // Safely handles the missing 'showtimes' field
      showtimeStrings: List<String>.from(data['showtimes'] ?? []),
    );
  }
}