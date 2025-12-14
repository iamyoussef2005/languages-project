import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/features/reservations/cubit/booking_cubit.dart';
import 'package:project1/features/reservations/cubit/booking_state.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Bookings"),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Current"),
              Tab(text: "Past"),
              Tab(text: "Cancelled"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            if (state is BookingLoading || state is BookingInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BookingError) {
              return Center(child: Text(state.message));
            }

            if (state is BookingLoaded) {
              return TabBarView(
                children: [
                  _buildList(state.pending),
                  _buildList(state.current, canCancel: true),
                  _buildList(state.past),
                  _buildList(state.cancelled),
                  _buildList(state.rejected),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildList(List<BookingModel> bookings, {bool canCancel = false}) {
    if (bookings.isEmpty) {
      return const Center(child: Text("No bookings"));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final b = bookings[index];

        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(b.apartment.address),
            subtitle: Text(
              "${b.checkIn.toString().split(' ').first} → ${b.checkOut.toString().split(' ').first}\n"
              "${b.apartment.city}, ${b.apartment.province}",
            ),
            trailing: canCancel
                ? TextButton(
                    onPressed: () async {
                      await context.read<BookingCubit>().cancelBooking(b.id);
                    },
                    child: const Text("Cancel"),
                  )
                : Text(
                    b.status.toUpperCase(),
                    style: const TextStyle(color: Colors.grey),
                  ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: bookings.length,
    );
  }
}
