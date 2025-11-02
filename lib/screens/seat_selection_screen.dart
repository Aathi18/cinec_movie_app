import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/showtime.dart';
import '../services/booking_service.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Showtime showtime;
  final String movieTitle;

  const SeatSelectionScreen({
    super.key,
    required this.showtime,
    required this.movieTitle,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final BookingService _bookingService = BookingService();
  final List<String> _selectedSeats = [];
  bool _isBooking = false;

  // Define cinema layout (e.g., 5 rows, 10 columns)
  static const int _numRows = 5;
  static const int _seatsPerRow = 10;

  // Use the price from the showtime object
  double get _seatPrice => widget.showtime.price;

  // Function to map row/col index to a seat name (A1, B5, etc.)
  String _getSeatName(int row, int col) {
    final rowLetter = String.fromCharCode('A'.codeUnitAt(0) + row);
    return '$rowLetter${col + 1}';
  }

  // Function to handle seat taps
  void _toggleSeat(String seatName) {
    setState(() {
      if (_selectedSeats.contains(seatName)) {
        _selectedSeats.remove(seatName);
      } else {
        _selectedSeats.add(seatName);
      }
    });
  }

  // Function to handle the final booking process
  Future<void> _handleBooking() async {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one seat.')),
      );
      return;
    }

    setState(() => _isBooking = true);

    final totalAmount = _selectedSeats.length * _seatPrice;

    try {
      await _bookingService.createBooking(
        showtime: widget.showtime,
        movieTitle: widget.movieTitle,
        selectedSeats: _selectedSeats,
        totalAmount: totalAmount,
      );

      // Success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Booking confirmed for ${widget.movieTitle}! Total: \$${totalAmount.toStringAsFixed(2)}')),
        );
        // Navigate back to Home or History
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushNamed('/booking-history');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _selectedSeats.length * _seatPrice;
    final showtimeString = DateFormat('EEEE, h:mm a').format(widget.showtime.time);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movieTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${widget.showtime.theater} - $showtimeString',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Screen Indicator
          Container(
            height: 50,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple, width: 2),
            ),
            child: const Center(
              child: Text(
                'SCREEN',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Seat Grid
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_numRows, (row) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_seatsPerRow, (col) {
                          return _buildSeat(row, col);
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

          // Legend and Booking Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(Colors.grey.shade700, 'Available'),
                    _buildLegendItem(Colors.red.shade900, 'Booked'),
                    _buildLegendItem(Colors.deepPurple, 'Selected'),
                  ],
                ),
                const Divider(height: 30, color: Colors.white10),
                // Summary and Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seats: ${_selectedSeats.isEmpty ? 'None' : _selectedSeats.join(', ')}',
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Total: \$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    _isBooking
                        ? const CircularProgressIndicator(
                            color: Colors.deepPurple)
                        : ElevatedButton(
                            onPressed: _handleBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Confirm Booking',
                                style: TextStyle(fontSize: 18)),
                          ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget to display a single seat
  Widget _buildSeat(int row, int col) {
    final seatName = _getSeatName(row, col);
    final isBooked = widget.showtime.bookedSeats.contains(seatName);
    final isSelected = _selectedSeats.contains(seatName);

    Color seatColor;
    if (isBooked) {
      seatColor = Colors.red.shade900;
    } else if (isSelected) {
      seatColor = Colors.deepPurple;
    } else {
      seatColor = Colors.grey.shade700;
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: isBooked ? null : () => _toggleSeat(seatName),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: seatColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.deepPurple.shade300, blurRadius: 4)
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              isBooked ? 'X' : seatName.substring(1), // Show seat number
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for the color legend
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}