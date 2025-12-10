import 'package:dio/dio.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';

class BookingService {
  final Dio dio;

  BookingService({required this.dio});

  Future<List<BookingModel>> getBookings() async {
    try {
      final response = await dio.get("/bookings");
      if (response.statusCode == 200) {
        final list = response.data['data'] as List;
        return list.map((e) => BookingModel.fromJson(e)).toList();
      }
      throw Exception("Failed to load bookings, status: ${response.statusCode}");
    } catch (e) {
      throw Exception("Failed to load bookings: $e");
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await dio.post("/bookings/$bookingId/cancel");
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Failed to cancel booking, status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to cancel booking: $e");
    }
  }
}

