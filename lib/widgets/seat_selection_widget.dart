import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Data Models (Defined locally to prevent import conflicts) ---

/// Represents a single available movie screening.
class Showtime {
  final String id;
  // Using DocumentReference is best practice for relationships
  final DocumentReference movieId; 
  final DateTime time;
  // Corrected property name: use 'theater' instead of 'cinema'
  final String theater; 
  final double price;
  final int totalSeats;
  final List<String> bookedSeats;

  Showtime({
    required this.id,
    required this.movieId,
    required this.time,
    required this.theater,
    required this.price,
    required this.totalSeats,
    required this.bookedSeats,
  });

  // Factory constructor to create a Showtime from a Firestore document.
  // This replaces the old 'fromMap' and is correctly typed.
  factory Showtime.fromFirestore(DocumentSnapshot doc) {
    // Cast data safely
    final data = doc.data() as Map<String, dynamic>?; 
    
    // Safely parse fields
    final timestamp = data?['time'] as Timestamp?;
    final priceNum = data?['price'] as num?;

    return Showtime(
      id: doc.id,
      movieId: data?['movieId'] as DocumentReference? ?? FirebaseFirestore.instance.collection('movies').doc('unknown'), // Fallback
      time: timestamp?.toDate() ?? DateTime.now(),
      theater: data?['theater'] as String? ?? 'Unknown Theater',
      price: priceNum?.toDouble() ?? 0.0,
      totalSeats: data?['totalSeats'] as int? ?? 50,
      bookedSeats: List<String>.from(data?['bookedSeats'] as List? ?? []),
    );
  }
}

/// Represents a confirmed booking made by a user.
class Booking {
  final String id;
  final String userId; 
  final String movieTitle;
  final String theater; // Corrected property name from 'cinema' to 'theater'
  final DateTime showtime;
  final List<String> seats;
  final double totalAmount;
  final DateTime timestamp;

  Booking({
    required this.id,
    required this.userId,
    required this.movieTitle,
    required this.theater,
    required this.showtime,
    required this.seats,
    required this.totalAmount,
    required this.timestamp,
  });

  // Method to convert the model to a Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'movieTitle': movieTitle,
      'theater': theater,
      'showtime': Timestamp.fromDate(showtime),
      'seats': seats,
      'totalAmount': totalAmount,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Factory constructor to create a Booking from a Firestore map
  factory Booking.fromMap(Map<String, dynamic> data, String id) {
    return Booking(
      id: id,
      userId: data['userId'] as String? ?? 'unknown',
      movieTitle: data['movieTitle'] as String? ?? 'N/A',
      theater: data['theater'] as String? ?? 'N/A',
      showtime: (data['showtime'] as Timestamp).toDate(),
      seats: List<String>.from(data['seats'] as List? ?? []),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}


// --- Booking Service (Handles all database interaction) ---

class BookingService { 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Fetch Showtimes for a specific movie
  Stream<List<Showtime>> getShowtimesForMovie(String movieId) {
    // 1. Get the DocumentReference for the movie
    final movieRef = _firestore.collection('movies').doc(movieId);

    // 2. Build the query
    final now = DateTime.now();
    final query = _firestore.collection('showtimes')
        .where('movieId', isEqualTo: movieRef) // Filter by DocumentReference
        .where('time', isGreaterThanOrEqualTo: now)
        .orderBy('time', descending: false);

    // 3. Listen for real-time updates and map the results
    return query.snapshots().map((snapshot) {
      // Correctly maps the snapshot documents using the new factory
      return snapshot.docs
          .map((doc) => Showtime.fromFirestore(doc))
          .toList();
    });
  }

  // 2. Process a new booking (Core of Requirement #3)
  Future<void> createBooking({
    required Showtime showtime,
    required String movieTitle,
    required List<String> selectedSeats,
    required double totalAmount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final userId = user.uid;
    final currentTime = DateTime.now();

    // Start a Firestore Transaction to ensure atomic seat update and booking creation
    await _firestore.runTransaction((transaction) async {
      // Step A: Get the latest showtime document inside the transaction
      final showtimeRef = _firestore.collection('showtimes').doc(showtime.id);
      final showtimeSnapshot = await transaction.get(showtimeRef);
      
      if (!showtimeSnapshot.exists) {
        throw Exception('Showtime no longer exists.');
      }

      final currentBookedSeats = List<String>.from(showtimeSnapshot.data()?['bookedSeats'] ?? []);
      
      // Check for conflicts (double booking)
      for (var seat in selectedSeats) {
        if (currentBookedSeats.contains(seat)) {
          throw Exception('Seat $seat was just booked by another user. Please re-select.');
        }
      }

      // Step B: Update the showtime document with the new booked seats
      final newBookedSeats = [...currentBookedSeats, ...selectedSeats];
      transaction.update(showtimeRef, {'bookedSeats': newBookedSeats});

      // Step C: Create the new booking document 
      final newBooking = Booking(
        id: '', // Firestore generates this ID
        userId: userId,
        movieTitle: movieTitle,
        theater: showtime.theater, // FIXED: Used the correct 'theater' property
        showtime: showtime.time,
        seats: selectedSeats,
        totalAmount: totalAmount,
        timestamp: currentTime,
      );

      final bookingRef = _firestore.collection('bookings').doc();
      transaction.set(bookingRef, newBooking.toMap());
    });
  }
  
  // 3. Fetch Booking History (Core of Requirement #4)
  Stream<List<Booking>> getBookingHistory() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      // Return an empty stream if no user is logged in
      return Stream.value([]);
    }

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        // Sort by timestamp descending (newest first)
        .orderBy('timestamp', descending: true) 
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Use the Booking.fromMap factory
        return Booking.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
