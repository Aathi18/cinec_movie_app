import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/add_showtimes.dart';

/// A reusable form dialog to add or edit a showtime.
///
/// Usage:
/// showDialog(context: context, builder: (_) => ShowtimeForm(movieId: '...'));
class ShowtimeForm extends StatefulWidget {
  final String movieId;
  final String? docId; // If provided, we're editing an existing showtime
  final DateTime? initialTime;
  final String? initialTheater;
  final double? initialPrice;
  final int? initialTotalSeats;

  const ShowtimeForm({
    Key? key,
    required this.movieId,
    this.docId,
    this.initialTime,
    this.initialTheater,
    this.initialPrice,
    this.initialTotalSeats,
  }) : super(key: key);

  @override
  State<ShowtimeForm> createState() => _ShowtimeFormState();
}

class _ShowtimeFormState extends State<ShowtimeForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDateTime;
  late String _theater;
  late double _price;
  late int _totalSeats;

  final List<String> _screens = ['Screen 1', 'Screen 2', 'Screen 3'];

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialTime ?? DateTime.now().add(const Duration(hours: 1));
    _theater = widget.initialTheater ?? _screens.first;
    _price = widget.initialPrice ?? (ShowtimeManager.moviePrices[widget.movieId] ?? 500.0);
    _totalSeats = widget.initialTotalSeats ?? 200;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;
    setState(() => _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (widget.docId == null) {
      final showtime = ShowtimeData(
        movieId: widget.movieId,
        theater: _theater,
        time: _selectedDateTime,
        price: _price,
        totalSeats: _totalSeats,
        bookedSeats: <String>[],
      );
      await ShowtimeManager.addShowtime(showtime);
    } else {
      await ShowtimeManager.editShowtime(widget.docId!, time: _selectedDateTime, theater: _theater, price: _price, totalSeats: _totalSeats);
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _onDelete() async {
    if (widget.docId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete showtime?'),
        content: const Text('Are you sure you want to delete this showtime?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ShowtimeManager.deleteShowtime(widget.docId!);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.docId == null ? 'Add Showtime' : 'Edit Showtime', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  onTap: _pickDateTime,
                  decoration: InputDecoration(labelText: 'Date & Time', hintText: DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDateTime)),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _theater,
                  items: _screens.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _theater = v ?? _theater),
                  decoration: const InputDecoration(labelText: 'Screen'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _price.toStringAsFixed(2),
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid price' : null,
                  onSaved: (v) => _price = double.parse(v!),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: '$_totalSeats',
                  decoration: const InputDecoration(labelText: 'Total Seats'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter valid number' : null,
                  onSaved: (v) => _totalSeats = int.parse(v!),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.docId != null)
                      TextButton(onPressed: _onDelete, child: const Text('Delete', style: TextStyle(color: Colors.red))),
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: _onSave, child: const Text('Save')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
