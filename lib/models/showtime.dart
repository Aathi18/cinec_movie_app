import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a movie showtime
class Showtime {
  final String id;
  final String movieId;
  final DateTime time;
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

  /// Creates a Showtime instance from a Firestore document
  factory Showtime.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    print('Creating Showtime from data: $data');
    
    final timeData = data['time'];
    final DateTime datetime;
    
    if (timeData is Timestamp) {
      datetime = timeData.toDate();
    } else if (timeData is DateTime) {
      datetime = timeData;
    } else {
      datetime = DateTime.now();
      print('Warning: Invalid time data in showtime document ${doc.id}');
    }
    
    return Showtime(
      id: doc.id,
      movieId: data['movieId'] as String? ?? '',
      time: datetime,
      theater: data['theater'] as String? ?? 'Unknown Screen',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      totalSeats: data['totalSeats'] as int? ?? 200,
      bookedSeats: List<String>.from(data['bookedSeats'] as List? ?? []),
    );
  }

  /// Converts the showtime instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'movieId': movieId,
      'time': time,
      'theater': theater,
      'price': price,
      'totalSeats': totalSeats,
      'bookedSeats': bookedSeats,
    };
  }

  /// Creates a copy of the showtime with modified properties
  Showtime copyWith({
    String? id,
    String? movieId,
    DateTime? time,
    String? theater,
    double? price,
    int? totalSeats,
    List<String>? bookedSeats,
  }) {
    return Showtime(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      time: time ?? this.time,
      theater: theater ?? this.theater,
      price: price ?? this.price,
      totalSeats: totalSeats ?? this.totalSeats,
      bookedSeats: bookedSeats ?? this.bookedSeats,
    );
  }
}