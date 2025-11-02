import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final DocumentReference userId;
  final DocumentReference showtimeRef;
  final List<String> seats;
  final double totalAmount;
  final DateTime bookingDate;
  final String movieTitle;

  Booking({
    required this.id,
    required this.userId,
    required this.showtimeRef,
    required this.seats,
    required this.totalAmount,
    required this.bookingDate,
    required this.movieTitle,
  });

  // Factory constructor to create a Booking instance from a Firestore document.
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] as DocumentReference,
      showtimeRef: data['showtimeRef'] as DocumentReference,
      seats: List<String>.from(data['seats'] ?? []),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      movieTitle: data['movieTitle'] as String? ?? 'N/A',
    );
  }

  // Method to convert the model back to a Firestore map for saving.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'showtimeRef': showtimeRef,
      'seats': seats,
      'totalAmount': totalAmount,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'movieTitle': movieTitle,
    };
  }
}