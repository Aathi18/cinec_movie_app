import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap; // The function to call when tapped

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap, // Make it required in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C3E50),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: InkWell( // Use InkWell to make the card tappable
        onTap: onTap, // Use the onTap function passed from the home screen
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterUrl,
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  // Error builder for when the image fails to load
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey.shade700,
                    child: const Center(
                      child: Icon(Icons.movie, color: Colors.white54, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Movie Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${movie.genre} | ${movie.durationMinutes} mins',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      movie.synopsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}