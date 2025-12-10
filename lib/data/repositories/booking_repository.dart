import 'package:project1/data/services/booking_service.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';

class BookingRepository {
  final BookingService service;

  BookingRepository(this.service);

  Future<List<BookingModel>> getBookings() => service.getBookings();

  Future<void> cancelBooking(String bookingId) => service.cancelBooking(bookingId);
}

