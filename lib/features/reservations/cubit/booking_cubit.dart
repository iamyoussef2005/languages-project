import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/repositories/booking_repository.dart';
import 'package:project1/features/reservations/cubit/booking_state.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository repository;

  BookingCubit(this.repository) : super(BookingInitial());

  Future<void> loadBookings() async {
    emit(BookingLoading());

    try {
      final bookings = await repository.getBookings();

      final now = DateTime.now();

      List<BookingModel> pending = [];
      List<BookingModel> rejected = [];
      List<BookingModel> cancelled = [];
      List<BookingModel> approvedCurrent = [];
      List<BookingModel> approvedPast = [];
      List<BookingModel> completed = [];

      for (var b in bookings) {
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
            if (b.checkOut.isAfter(now)) {
              approvedCurrent.add(b);     // حالي
            } else {
              approvedPast.add(b);        // سابق
            }
            break;

          case 'completed':
            completed.add(b);
            break;
        }
      }

      emit(BookingLoaded(
        pending: pending,
        current: approvedCurrent,
        past: approvedPast,
        cancelled: cancelled,
        rejected: rejected,
        completed: completed,
      ));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> cancelBooking(int id) async {
    emit(BookingLoading());
    try {
      await repository.cancelBooking(id); // تم تعديل المعامل
      await loadBookings();
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // إضافة حجز جديد
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

      if (result['success']) {
        emit(BookingSuccess(result['message'])); // حالة نجاح
      } else {
        emit(BookingError(result['message'])); // حالة فشل
      }
    } catch (e) {
      emit(BookingError("Failed to create booking: $e"));
    }
  }
}
