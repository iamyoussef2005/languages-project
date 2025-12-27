import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project1/features/home/presentation/pages/edit_booking_page.dart';
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
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: color.primary,
          iconTheme: IconThemeData(color: color.onPrimary),
          title: Text(
            "My Bookings",
            style: GoogleFonts.poppins(
              color: color.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: color.onPrimary,
            unselectedLabelColor: color.onPrimary.withOpacity(0.7),
            indicatorColor: color.onPrimary,
            tabs: const [
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
              return Center(
                child: CircularProgressIndicator(
                  color: color.primary,
                ),
              );
            }

            if (state is BookingError) {
              return Center(
                child: Text(
                  state.message,
                  style: GoogleFonts.poppins(color: color.error),
                ),
              );
            }

            if (state is BookingLoaded) {
              return TabBarView(
                children: [
                  _buildList(state.pending, canCancel: true),
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
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    if (bookings.isEmpty) {
      return Center(
        child: Text(
          "No bookings",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color.onSurface,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final b = bookings[index];

        return Card(
          color: color.surface,
          shadowColor: color.shadow,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.apartment.address,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${b.checkIn.toString().split(' ').first} → ${b.checkOut.toString().split(' ').first}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${b.apartment.city}, ${b.apartment.province}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),

                if (canCancel)
                  Row(
                    children: [
                      // Edit
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditBookingPage(booking: b),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit, size: 18, color: color.primary),
                        label: Text(
                          "Edit",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: color.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Cancel
                      FilledButton.icon(
                        onPressed: () {
                          context.read<BookingCubit>().cancelBooking(b.id);
                        },
                        icon: Icon(Icons.close, size: 18, color: color.onError),
                        label: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: color.onError,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: color.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      b.status.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
