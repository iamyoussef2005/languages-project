import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/repositories/booking_repository.dart';
import 'package:project1/features/reservations/cubit/booking_state.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository repository;

  BookingCubit(this.repository) : super(BookingInitial());

  // ==========================
  // حجوزات المستأجر
  // ==========================

  Future<void> loadBookings() async {
    emit(BookingLoading());

    try {
      final bookings = await repository.getBookings();
      _emitCategorizedBookings(bookings);
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      await repository.cancelBooking(bookingId);
      await loadBookings();
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> updateBooking({
    required int bookingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestsCount,
  }) async {
    emit(BookingLoading());

    try {
      await repository.updateBooking(
        bookingId: bookingId,
        checkIn: checkIn,
        checkOut: checkOut,
        guestsCount: guestsCount,
      );

      await loadBookings();
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> createBooking({
    required int apartmentId,
    required String checkIn,
    required String checkOut,
    required int personNumber,
  }) async {
    emit(BookingLoading());

    try {
      final result = await repository.createBooking(
        apartmentId: apartmentId,
        checkIn: checkIn,
        checkOut: checkOut,
        personNumber: personNumber,
      );

      result['success']
          ? emit(BookingSuccess(result['message']))
          : emit(BookingError(result['message']));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ==========================
  // حجوزات المالك
  // ==========================

  Future<void> loadOwnerBookings() async {
    emit(BookingLoading());

    try {
      final bookings = await repository.getOwnerBookings();
      _emitCategorizedBookings(bookings);
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> approveBooking(int bookingId) async {
    try {
      final result = await repository.approveBooking(bookingId);
      emit(BookingSuccess(result['message']));
      await loadOwnerBookings();
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> rejectBooking(int bookingId) async {
    try {
      final result = await repository.rejectBooking(bookingId);
      emit(BookingSuccess(result['message']));
      await loadOwnerBookings();
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ==========================
  // Helper
  // ==========================

  void _emitCategorizedBookings(List<BookingModel> bookings) {
    final now = DateTime.now();

    final pending = <BookingModel>[];
    final rejected = <BookingModel>[];
    final cancelled = <BookingModel>[];
    final approvedCurrent = <BookingModel>[];
    final approvedPast = <BookingModel>[];
    final completed = <BookingModel>[];

    for (final b in bookings) {
      switch (b.status) {
        case 'pending':
          pending.add(b);
          break;
        case 'rejected':
          rejected.add(b);
          break;
        case 'cancelled':
          cancelled.add(b);
          break;
        case 'approved':
          b.checkOut.isAfter(now)
              ? approvedCurrent.add(b)
              : approvedPast.add(b);
          break;
        case 'completed':
          completed.add(b);
          break;
      }
    }

    emit(
      BookingLoaded(
        pending: pending,
        current: approvedCurrent,
        past: approvedPast,
        cancelled: cancelled,
        rejected: rejected,
        completed: completed,
      ),
    );
  }
}
