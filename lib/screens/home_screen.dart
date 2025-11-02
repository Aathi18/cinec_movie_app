import 'package:flutter/material.dart';
import '../services/movie_service.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/logout_button.dart';
import '../utils/add_showtimes.dart';
import '../utils/movie_admin.dart';
import 'package:flutter/foundation.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// STEP 2: Create the State class
class _HomeScreenState extends State<HomeScreen> {
  // Move instance variables into the State class
  final MovieService _movieService = MovieService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinec Movie Bookings'),
        actions: [
          // Temporary button to add showtimes
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () async {
              await ShowtimeManager.addShowtimes();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added showtimes!')),
              );
            },
            tooltip: 'Add Showtimes',
          ),
          // Debug-only button to populate movie synopses
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final results = await MovieAdmin.populateSynopses();
                final successCount = results.values.where((v) => v).length;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Populated $successCount synopses')),
                );
              },
              tooltip: 'Populate Synopses (debug)',
            ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white70),
            onPressed: () => Navigator.of(context).pushNamed('/booking-history'),
            tooltip: 'Booking History',
          ),
          const LogoutButton(),
        ],
      ),
      body: StreamBuilder<List<Movie>>(
        stream: _movieService.getMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading movies: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No movies currently showing. Check back later!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            );
          }

          final movies = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                onTap: () {
                  Navigator.of(context).pushNamed('/movie-detail', arguments: movie);
                },
              );
            },
          );
        },
      ),
    );
  }
}