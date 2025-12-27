import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project1/features/reservations/cubit/booking_cubit.dart';
import 'package:project1/features/reservations/cubit/booking_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OwnerBookingsPage extends StatefulWidget {
  const OwnerBookingsPage({super.key});

  @override
  _OwnerBookingsPageState createState() => _OwnerBookingsPageState();
}

class _OwnerBookingsPageState extends State<OwnerBookingsPage> {
  @override
  void initState() {
    super.initState();
    // استدعاء التابع loadBookings فقط عند أول بناء للصفحة
    context.read<BookingCubit>().loadOwnerBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Owner's Bookings",
          style: GoogleFonts.poppins(),
        ),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookingError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is BookingLoaded) {
            return ListView.builder(
              itemCount: state.pending.length, 
              itemBuilder: (context, index) {
                final booking = state.pending[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apartment: ${booking.apartment.city} - ${booking.apartment.address}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Check-in Date: ${booking.checkIn.toLocal()}',
                          style: GoogleFonts.poppins(),
                        ),
                        Text(
                          'Check-out Date: ${booking.checkOut.toLocal()}',
                          style: GoogleFonts.poppins(),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Persons : ${booking.guestsCount}',
                          style: GoogleFonts.poppins(),
                        ),
                        Text(
                          'Total Price: ${booking.totalPrice} \$',
                          style: GoogleFonts.poppins(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.read<BookingCubit>().approveBooking(booking.id);
                              },
                              child: Text(
                                'Accept',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<BookingCubit>().rejectBooking(booking.id);
                              },
                              child: Text(
                                'Reject',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No bookings available.'));
        },
      ),
    );
  }
}

