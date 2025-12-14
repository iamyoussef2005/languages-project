import 'package:project1/data/services/booking_service.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';

class BookingRepository {
  final BookingService service;

  BookingRepository(this.service);

  Future<List<BookingModel>> getBookings() => service.getBookings();

  Future<void> cancelBooking(int bookingId) => service.cancelBooking(bookingId);

  // إضافة حجز جديد
  Future<Map<String, dynamic>> createBooking({
    required int apartmentId,
    required String checkIn,
    required String checkOut,
    required int personNumber,
  }) => service.createBooking(
        apartmentId: apartmentId,
        checkIn: checkIn,
        checkOut: checkOut,
        personNumber: personNumber,
      );
}
