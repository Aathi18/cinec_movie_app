import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movie.dart';
import '../models/showtime.dart';
import '../services/booking_service.dart';
import 'seat_selection_screen.dart';
import '../widgets/showtime_form.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Showtime? _selectedShowtime;
  final BookingService _bookingService = BookingService();

  void _goToSeatSelection(BuildContext context) {
    if (_selectedShowtime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a showtime to continue.')),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SeatSelectionScreen(
        showtime: _selectedShowtime!,
        movieTitle: widget.movie.title,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.movie.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Showtime Selection (placed above poster)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Showtimes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  StreamBuilder<List<Showtime>>(
                    stream: _bookingService.getShowtimesForMovie(widget.movie.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final showtimes = snapshot.data ?? [];
                      if (showtimes.isEmpty) {
                        return const Text('No showtimes available.');
                      }

                      // Group showtimes by date
                      final Map<DateTime, List<Showtime>> showtimesByDate = {};
                      for (var showtime in showtimes) {
                        final date = DateTime(showtime.time.year, showtime.time.month, showtime.time.day);
                        showtimesByDate.putIfAbsent(date, () => []).add(showtime);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var date in showtimesByDate.keys)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    DateFormat('EEEE, MMMM d').format(date),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                                  ),
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: showtimesByDate[date]!.map((showtime) {
                                    final isSelected = showtime.id == _selectedShowtime?.id;
                                    return Card(
                                      color: isSelected ? Colors.deepPurple : Colors.grey.shade800,
                                      child: InkWell(
                                        onTap: () => setState(() => _selectedShowtime = showtime),
                                        onLongPress: () async {
                                          final result = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => ShowtimeForm(
                                              movieId: widget.movie.id,
                                              docId: showtime.id,
                                              initialTime: showtime.time,
                                              initialTheater: showtime.theater,
                                              initialPrice: showtime.price,
                                              initialTotalSeats: showtime.totalSeats,
                                            ),
                                          );
                                          if (result == true) setState(() {});
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                DateFormat('h:mm a').format(showtime.time),
                                                style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.white70),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(showtime.theater, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey)),
                                              const SizedBox(height: 4),
                                              Text('Rs. ${showtime.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Poster image (use AspectRatio so images align consistently)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    widget.movie.posterUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (ctx, err, st) => Container(
                      color: Colors.grey.shade800,
                      child: const Center(child: Icon(Icons.movie, size: 64, color: Colors.white38)),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Movie details (title, genre, synopsis)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.movie.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('${widget.movie.genre} | ${widget.movie.durationMinutes} mins', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Text(widget.movie.synopsis, style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Continue button at bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () => _goToSeatSelection(context),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.deepPurple),
                child: Text(
                  _selectedShowtime == null ? 'Select a Showtime to Continue' : 'Continue with ${DateFormat('h:mm a').format(_selectedShowtime!.time)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}