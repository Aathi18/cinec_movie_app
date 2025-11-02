import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetches all movies from the Firestore 'movies' collection
  // Returns a stream for real-time updates
  Stream<List<Movie>> getMovies() {
    return _firestore.collection('movies').snapshots().map((snapshot) {
      try {
        print('Number of movies found: ${snapshot.docs.length}');
        return snapshot.docs.map((doc) {
          print('Processing movie with ID: ${doc.id}');
          final data = doc.data();
          print('Movie data: $data');
          return Movie.fromMap(doc.data(), doc.id);
        }).toList();
      } catch (e) {
        print('Error processing movies: $e');
        rethrow;
      }
    });
  }
}