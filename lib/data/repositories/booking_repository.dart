// import 'package:project1/data/services/booking_service.dart';
// import 'package:project1/features/reservations/data/models/booking_model.dart';

// class BookingRepository {
//   final BookingService service;

//   BookingRepository(this.service);

//   Future<List<BookingModel>> getBookings() => service.getBookings();

//   Future<void> cancelBooking(int bookingId) => service.cancelBooking(bookingId);

//   // إضافة حجز جديد
//   Future<Map<String, dynamic>> createBooking({
//     required int apartmentId,
//     required String checkIn,
//     required String checkOut,
//     required int personNumber,
//   }) => service.createBooking(
//         apartmentId: apartmentId,
//         checkIn: checkIn,
//         checkOut: checkOut,
//         personNumber: personNumber,
//       );


//       Future<BookingModel> updateBooking({
//   required int bookingId,
//   required DateTime checkIn,
//   required DateTime checkOut,
//   required int guestsCount,
// }) {
//   return service.updateBooking(
//     bookingId: bookingId,
//     checkIn: checkIn,
//     checkOut: checkOut,
//     guestsCount: guestsCount,
//   );
// }

//   Future<List<BookingModel>> getOwnerBookings() => service.getOwnerBookings();

//   Future<Map<String, dynamic>> approveBooking(int bookingId) =>
//       service.approveBooking(bookingId);

//   Future<Map<String, dynamic>> rejectBooking(int bookingId) =>
//       service.rejectBooking(bookingId);

// }
import 'package:project1/data/services/booking_service.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';

class BookingRepository {
  final BookingService service;

  BookingRepository(this.service);

  // ==========================
  // حجوزات المستأجر
  // ==========================

  Future<List<BookingModel>> getBookings() {
    return service.getBookings();
  }

  Future<void> cancelBooking(int bookingId) {
    return service.cancelBooking(bookingId);
  }

  // إنشاء حجز جديد
  Future<Map<String, dynamic>> createBooking({
    required int apartmentId,
    required String checkIn,
    required String checkOut,
    required int personNumber,
  }) {
    return service.createBooking(
      apartmentId: apartmentId,
      checkIn: checkIn,
      checkOut: checkOut,
      personNumber: personNumber,
    );
  }

  // تحديث الحجز
  Future<BookingModel> updateBooking({
    required int bookingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestsCount,
  }) {
    return service.updateBooking(
      bookingId: bookingId,
      checkIn: checkIn,
      checkOut: checkOut,
      guestsCount: guestsCount,
    );
  }

  // ==========================
  // حجوزات المالك
  // ==========================

  Future<List<BookingModel>> getOwnerBookings() {
    return service.getOwnerBookings();
  }

  Future<Map<String, dynamic>> approveBooking(int bookingId) {
    return service.approveBooking(bookingId);
  }

  Future<Map<String, dynamic>> rejectBooking(int bookingId) {
    return service.rejectBooking(bookingId);
  }
}
