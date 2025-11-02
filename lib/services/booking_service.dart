import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/showtime.dart';
import '../models/booking.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches showtimes for a specific movie
  Stream<List<Showtime>> getShowtimesForMovie(String movieId) {
    print('Fetching showtimes for movie ID: $movieId');
    
    // Query showtimes for this movie, ordered by time
    return _db
        .collection('showtimes')
        .where('movieId', isEqualTo: movieId)
        .orderBy('time')
        .snapshots()
        .map((snapshot) {
          print('Found ${snapshot.docs.length} showtimes for movie $movieId');
          
          // Convert documents to Showtime objects
          final List<Showtime> showtimes = snapshot.docs.map((doc) {
            try {
              return Showtime.fromFirestore(doc);
            } catch (e) {
              print('Error processing showtime ${doc.id}: $e');
              rethrow;
            }
          }).toList();

          // Filter out past showtimes
          final now = DateTime.now();
          final futureShowtimes = showtimes.where((showtime) {
            return showtime.time.isAfter(now);
          }).toList();

          print('${futureShowtimes.length} upcoming showtimes found');
          return futureShowtimes;
        });
  }

  /// Creates a new booking using a transaction.
  /// NOTE: This will fail until the data structure in your 'bookings' collection is corrected.
  Future<void> createBooking({
    required Showtime showtime,
    required String movieTitle,
    required List<String> selectedSeats,
    required double totalAmount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User is not signed in.");
    }

    // This code correctly uses Document References.
    // Your current database uses strings, which will need to be fixed.
    final userIdRef = _db.collection('users').doc(user.uid);
    final showtimeRef = _db.collection('showtimes').doc(showtime.id);

    return _db.runTransaction((transaction) async {
      final freshShowtimeSnapshot = await transaction.get(showtimeRef);
      if (!freshShowtimeSnapshot.exists) {
        throw Exception("This showtime is no longer available.");
      }
      final freshShowtime = Showtime.fromFirestore(freshShowtimeSnapshot);

      for (var seat in selectedSeats) {
        if (freshShowtime.bookedSeats.contains(seat)) {
          throw Exception(
            "Seat $seat has just been booked. Please select another.",
          );
        }
      }

      final newBooking = Booking(
        id: '',
        userId: userIdRef,
        showtimeRef: showtimeRef,
        seats: selectedSeats,
        totalAmount: totalAmount,
        bookingDate: DateTime.now(),
        movieTitle: movieTitle,
      );

      transaction.update(showtimeRef, {
        'bookedSeats': FieldValue.arrayUnion(selectedSeats),
      });

      transaction.set(
        _db.collection('bookings').doc(),
        newBooking.toFirestore(),
      );
    });
  }

  /// Fetches the booking history for the current user.
  /// NOTE: This will also fail until the data structure in your 'bookings' collection is corrected.
  Stream<List<Booking>> getBookingHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    // This query expects 'userId' to be a Document Reference.
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: _db.collection('users').doc(user.uid))
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();
        });
  }
}
