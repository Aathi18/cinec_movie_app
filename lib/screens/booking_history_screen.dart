import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingService bookingService = BookingService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
      ),
      body: StreamBuilder<List<Booking>>(
        stream: bookingService.getBookingHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('You have no past or upcoming bookings.'),
            );
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                color: Colors.grey.shade900,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  isThreeLine: true,
                  title: Text(
                    booking.movieTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    'Seats: ${booking.seats.join(', ')}\nTotal: \$${booking.totalAmount.toStringAsFixed(2)}',
                  ),
                  trailing: Text(
                    DateFormat('MMM d, yyyy').format(booking.bookingDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.deepPurple.shade200,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

