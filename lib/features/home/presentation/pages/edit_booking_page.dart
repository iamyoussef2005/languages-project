import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/features/reservations/cubit/booking_cubit.dart';
import 'package:project1/features/reservations/cubit/booking_state.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';

class EditBookingPage extends StatefulWidget {
  final BookingModel booking;

  const EditBookingPage({
    super.key,
    required this.booking,
  });

  @override
  State<EditBookingPage> createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _checkIn;
  late DateTime _checkOut;
  late TextEditingController _guestsController;

  @override
  void initState() {
    super.initState();
    _checkIn = widget.booking.checkIn;
    _checkOut = widget.booking.checkOut;
    _guestsController =
        TextEditingController(text: widget.booking.guestsCount.toString());
  }

  @override
  void dispose() {
    _guestsController.dispose();
    super.dispose();
  }

Future<void> _pickCheckIn() async {
  final firstDate = DateTime.now().add(const Duration(days: 1));

  final initialDate =
      _checkIn.isBefore(firstDate) ? firstDate : _checkIn;

  final date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );

  if (date != null) {
    setState(() {
      _checkIn = date;
      if (!_checkOut.isAfter(_checkIn)) {
        _checkOut = _checkIn.add(const Duration(days: 1));
      }
    });
  }
}


Future<void> _pickCheckOut() async {
  final firstDate = _checkIn.add(const Duration(days: 1));

  final initialDate =
      _checkOut.isBefore(firstDate) ? firstDate : _checkOut;

  final date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );

  if (date != null) {
    setState(() => _checkOut = date);
  }
}


  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<BookingCubit>().updateBooking(
          bookingId: widget.booking.id,
          checkIn: _checkIn,
          checkOut: _checkOut,
          guestsCount: int.parse(_guestsController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Booking"),
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is BookingLoaded) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            final isLoading = state is BookingLoading;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _DateField(
                      label: "Check-in date",
                      value: _checkIn,
                      onTap: _pickCheckIn,
                    ),
                    const SizedBox(height: 12),
                    _DateField(
                      label: "Check-out date",
                      value: _checkOut,
                      onTap: _pickCheckOut,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _guestsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Number of guests",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required";
                        }
                        final n = int.tryParse(value);
                        if (n == null || n < 1) {
                          return "Invalid number";
                        }
                        return null;
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Save Changes"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==============================================================================
// 🔧 Custom Date Field Widget
class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value.toString().split(' ').first,
        ),
      ),
    );
  }
}
