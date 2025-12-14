
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';

class BookingService {
  final Dio dio;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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

  Future<void> cancelBooking(int bookingId) async {
    try {
      final response = await dio.post("/bookings/$bookingId/cancel");
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Failed to cancel booking, status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to cancel booking: $e");
    }
  }

Future<Map<String, dynamic>> createBooking({
  required int apartmentId,
  required String checkIn,
  required String checkOut,
  required int personNumber,
}) async {
  try {
    final token = await _storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Unauthorized: token not found',
      };
    }

    final response = await dio.post(
      "/createBooking",
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
      data: {
        'apartment_id': apartmentId,
        'check_in': checkIn,
        'check_out': checkOut,
        'person_number': personNumber,
      },
    );

    // ✅ المرجع الصحيح للنجاح
    if (response.statusCode == 201) {
      return {
        'success': true,
        'message': response.data['message'],
        'booking': response.data['booking'] != null
            ? BookingModel.fromJson(response.data['booking'])
            : null,
      };
    }

    // أي حالة غير متوقعة
    return {
      'success': false,
      'message': response.data['message'] ?? 'Booking failed',
    };
  } on DioException catch (e) {
    return {
      'success': false,
      'message': e.response?.data['message']
          ?? e.response?.data['errors']
          ?? 'Server error',
    };
  }
}



}