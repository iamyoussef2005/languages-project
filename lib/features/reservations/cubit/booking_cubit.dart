import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/repositories/booking_repository.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository repository;

  BookingCubit(this.repository) : super(BookingInitial());

  Future<void> loadBookings() async {
    emit(BookingLoading());
    try {
      final bookings = await repository.getBookings();
      emit(_splitBookings(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    emit(BookingUpdating());
    try {
      await repository.cancelBooking(bookingId);
      // Reload to refresh lists
      final bookings = await repository.getBookings();
      emit(_splitBookings(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  BookingLoaded _splitBookings(List<BookingModel> bookings) {
    final now = DateTime.now();
    final current = <BookingModel>[];
    final past = <BookingModel>[];
    final cancelled = <BookingModel>[];

    for (final b in bookings) {
      if (b.isCancelled) {
        cancelled.add(b);
      } else if (b.endDate.isBefore(now)) {
        past.add(b);
      } else {
        current.add(b);
      }
    }

    return BookingLoaded(
      current: current,
      past: past,
      cancelled: cancelled,
    );
  }
}

