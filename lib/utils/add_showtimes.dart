import 'package:cloud_firestore/cloud_firestore.dart';

/// A model class for showtime data
class ShowtimeData {
  final String movieId;
  final String theater;
  final DateTime time;
  final double price;
  final int totalSeats;
  final List<String> bookedSeats;

  /// Creates a new showtime instance
  ShowtimeData({
    required this.movieId,
    required this.theater,
    required this.time,
    required this.price,
    required this.totalSeats,
    required this.bookedSeats,
  });

  /// Converts the showtime data to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'theater': theater,
      'time': Timestamp.fromDate(time),
      'price': price,
      'totalSeats': totalSeats,
      'bookedSeats': bookedSeats,
    };
  }
}

/// A utility class for managing showtimes
class ShowtimeManager {
  /// Firestore database instance
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Creates a DateTime for today (Nov 10, 2025) at a specific time
  static DateTime timeToday(int hour, int minute) {
    return DateTime(2025, 11, 17, hour, minute);
  }

  /// Creates a DateTime for tomorrow (Nov 10, 2025) at a specific time
  static DateTime timeTomorrow(int hour, int minute) {
    return DateTime(2025, 11,25, hour, minute);
  }

  /// Map of movie IDs to their ticket prices
  static final Map<String, double> moviePrices = {
    'H9RsfxlZK8gdw7hRw2xM': 600.0, // Beast
    'LEXOYJ6E0ppG67S2PGDn': 500.0, // Caribbean
    'SlB0kUnkM1BE4ffBK8In': 550.0, // Puli
    'aY11GLa6UxAxN1mX0CCh': 700.0, // Avengers
    'lUHTOcR1vE5yVuDlQn9y': 450.0, // Dude
    'mZA6Yhkxe9YlmAn2yLVb': 500.0, // Vinnaithandi Varuvaya
    'qKSGRRe2j9ojn3KQaVW5': 650.0, // Leo
    'uH7NLaeRfJv46ZJou4de': 550.0, // Ponniyin Selvan
  };

  /// Predefined showtime slots for each screen
  static final List<Map<String, dynamic>> timeSlots = [
    {'screen': 'Screen 1', 'time': timeToday(10, 30)},     // 10:30 AM today
    {'screen': 'Screen 2', 'time': timeToday(11, 00)},     // 11:00 AM today
    {'screen': 'Screen 3', 'time': timeToday(14, 30)},     // 2:30 PM today
    {'screen': 'Screen 1', 'time': timeToday(15, 00)},     // 3:00 PM today
    {'screen': 'Screen 2', 'time': timeToday(17, 30)},     // 5:30 PM today
    {'screen': 'Screen 3', 'time': timeToday(18, 00)},     // 6:00 PM today
    {'screen': 'Screen 1', 'time': timeToday(20, 30)},     // 8:30 PM today
    {'screen': 'Screen 2', 'time': timeToday(21, 00)},     // 9:00 PM today
    {'screen': 'Screen 1', 'time': timeTomorrow(11, 00)},  // 11:00 AM tomorrow
    {'screen': 'Screen 2', 'time': timeTomorrow(14, 30)},  // 2:30 PM tomorrow
    {'screen': 'Screen 3', 'time': timeTomorrow(15, 00)},  // 3:00 PM tomorrow
    {'screen': 'Screen 1', 'time': timeTomorrow(17, 30)},  // 5:30 PM tomorrow
    {'screen': 'Screen 2', 'time': timeTomorrow(18, 00)},  // 6:00 PM tomorrow
    {'screen': 'Screen 3', 'time': timeTomorrow(20, 30)},  // 8:30 PM tomorrow
  ];

  /// Adds multiple showtimes for all movies
  static Future<void> addShowtimes() async {
    // Remove existing showtimes (optional: helps keeping test data deterministic)
    try {
      final existing = await _db.collection('showtimes').get();
      for (final d in existing.docs) {
        await d.reference.delete();
      }
    } catch (e) {
      print('Error clearing existing showtimes: $e');
    }

    final movieIds = moviePrices.keys.toList();
    if (movieIds.isEmpty) {
      print('No movies found in moviePrices map.');
      return;
    }

    // Create 4 fixed times per screen and populate 5 consecutive days starting Nov 2, 2025.
    // Times per screen: 10:00, 14:30, 18:30, 21:30
    final screens = ['Screen 1', 'Screen 2', 'Screen 3'];
    final timesOfDay = [
      const {'h': 10, 'm': 0},
      const {'h': 14, 'm': 30},
      const {'h': 18, 'm': 30},
      const {'h': 21, 'm': 30},
    ];

    final startDate = DateTime(2025, 11, 17);
    final days = 7; // Nov 2,3,4,5,6

    // We'll iterate over each day, screen and time slot, and assign a movie in round-robin
    var slotCounter = 0;
    for (var dayOffset = 0; dayOffset < days; dayOffset++) {
      final date = startDate.add(Duration(days: dayOffset));

      for (var screenIndex = 0; screenIndex < screens.length; screenIndex++) {
        for (var t = 0; t < timesOfDay.length; t++) {
          final timeMap = timesOfDay[t];
          final slotDateTime = DateTime(date.year, date.month, date.day, timeMap['h']!, timeMap['m']!);

          // Assign a movie to this slot by round-robin through movieIds
          final movieId = movieIds[slotCounter % movieIds.length];
          final price = moviePrices[movieId]!;
          final showtime = ShowtimeData(
            movieId: movieId,
            theater: screens[screenIndex],
            time: slotDateTime,
            price: price,
            totalSeats: 200,
            bookedSeats: <String>[],
          );

          try {
            await _db.collection('showtimes').add(showtime.toMap());
            print('Added showtime for $movieId at ${showtime.theater} - ${showtime.time}');
          } catch (e) {
            print('Error adding showtime for $movieId: $e');
          }

          slotCounter++;
        }
      }
    }

    print('Finished adding all showtimes for $days days across ${screens.length} screens.');
  }

  /// Adds a single showtime document to Firestore
  static Future<void> addShowtime(ShowtimeData showtime) async {
    try {
      await _db.collection('showtimes').add(showtime.toMap());
      print('Added showtime for ${showtime.movieId} at ${showtime.theater} - ${showtime.time}');
    } catch (e) {
      print('Error adding showtime: $e');
      rethrow;
    }
  }

  /// Add a custom schedule for a given movie.
  ///
  /// schedule is a list of maps with keys:
  /// - 'time' : DateTime (required)
  /// - 'theater' : String (required)
  /// - 'price' : double (optional, falls back to moviePrices)
  /// - 'totalSeats' : int (optional, default 200)
  static Future<void> addCustomSchedule(String movieId, List<Map<String, dynamic>> schedule) async {
    final double defaultPrice = moviePrices[movieId] ?? 500.0;
    for (final item in schedule) {
      final DateTime time = item['time'] as DateTime;
      final String theater = item['theater'] as String;
      final double price = (item['price'] as double?) ?? defaultPrice;
      final int totalSeats = (item['totalSeats'] as int?) ?? 200;

      final showtime = ShowtimeData(
        movieId: movieId,
        theater: theater,
        time: time,
        price: price,
        totalSeats: totalSeats,
        bookedSeats: <String>[],
      );

      await addShowtime(showtime);
    }
  }

  /// Edit an existing showtime document by its document ID.
  /// Provide any of the optional fields to update.
  static Future<void> editShowtime(String docId, {DateTime? time, String? theater, double? price, int? totalSeats}) async {
    final Map<String, dynamic> updates = {};
    if (time != null) updates['time'] = Timestamp.fromDate(time);
    if (theater != null) updates['theater'] = theater;
    if (price != null) updates['price'] = price;
    if (totalSeats != null) updates['totalSeats'] = totalSeats;

    if (updates.isEmpty) return;

    try {
      await _db.collection('showtimes').doc(docId).update(updates);
      print('Updated showtime $docId with $updates');
    } catch (e) {
      print('Error updating showtime $docId: $e');
      rethrow;
    }
  }

  /// Delete a showtime document by its ID
  static Future<void> deleteShowtime(String docId) async {
    try {
      await _db.collection('showtimes').doc(docId).delete();
      print('Deleted showtime $docId');
    } catch (e) {
      print('Error deleting showtime $docId: $e');
      rethrow;
    }
  }

  /// Gets all showtimes for a specific movie
  static Future<List<ShowtimeData>> getMovieShowtimes(String movieId) async {
    try {
      final QuerySnapshot querySnapshot = await _db
          .collection('showtimes')
          .where('movieId', isEqualTo: movieId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ShowtimeData(
          movieId: data['movieId'] as String,
          theater: data['theater'] as String,
          time: (data['time'] as Timestamp).toDate(),
          price: (data['price'] as num).toDouble(),
          totalSeats: data['totalSeats'] as int,
          bookedSeats: List<String>.from(data['bookedSeats'] as List<dynamic>),
        );
      }).toList();
    } catch (e) {
      print('Error getting showtimes: $e');
      return <ShowtimeData>[];
    }
  }
}