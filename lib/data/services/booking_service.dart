import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';

class BookingService {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  BookingService({required this.dio});

  // =========================
  // Helper: set auth header
  // =========================
  Future<void> _setAuthHeader() async {
    final token = await _storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized: token not found');
    }

    dio.options.headers['Authorization'] = 'Bearer $token';
    dio.options.headers['Accept'] = 'application/json';
  }

  // =========================
  // Get user bookings
  // =========================
  Future<List<BookingModel>> getBookings() async {
    try {
      await _setAuthHeader();

      final response = await dio.get('/indexBooking');

      final list = response.data['bookings']['data'] as List;
      return list.map((e) => BookingModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load bookings');
    }
  }

  // =========================
  // Cancel booking
  // =========================
  Future<void> cancelBooking(int bookingId) async {
    try {
      await _setAuthHeader();

      await dio.post('/cancelBooking/$bookingId');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to cancel booking');
    }
  }

  // =========================
  // Create booking
  // =========================
  Future<Map<String, dynamic>> createBooking({
    required int apartmentId,
    required String checkIn,
    required String checkOut,
    required int personNumber,
  }) async {
    try {
      await _setAuthHeader();

      final response = await dio.post(
        '/createBooking',
        data: {
          'apartment_id': apartmentId,
          'check_in': checkIn,
          'check_out': checkOut,
          'person_number': personNumber,
        },
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'],
          'booking': response.data['booking'] != null
              ? BookingModel.fromJson(response.data['booking'])
              : null,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Booking failed',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ??
            e.response?.data['errors'] ??
            'Server error',
      };
    }
  }

  // =========================
  // Update booking
  // =========================
  Future<BookingModel> updateBooking({
    required int bookingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestsCount,
  }) async {
    try {
      await _setAuthHeader();

      final response = await dio.put(
        '/updateBooking/$bookingId',
        data: {
          'check_in': checkIn.toIso8601String().split('T').first,
          'check_out': checkOut.toIso8601String().split('T').first,
          'person_number': guestsCount,
        },
      );

      return BookingModel.fromJson(response.data['booking']);
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to update booking');
    }
  }

  // =========================
  // Owner bookings
  // =========================
  Future<List<BookingModel>> getOwnerBookings() async {
    try {
      await _setAuthHeader();

      final response = await dio.get('/ownerbookings');

      final list = response.data['bookings']['data'] as List;
      return list.map((e) => BookingModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load owner bookings');
    }
  }

  // =========================
  // Approve booking
  // =========================
  Future<Map<String, dynamic>> approveBooking(int bookingId) async {
    try {
      await _setAuthHeader();

      await dio.post('/approve-booking/$bookingId');

      return {'success': true, 'message': 'Booking approved successfully'};
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to approve booking');
    }
  }

  // =========================
  // Reject booking
  // =========================
  Future<Map<String, dynamic>> rejectBooking(int bookingId) async {
    try {
      await _setAuthHeader();

      final response = await dio.post('/reject-booking/$bookingId');

      return {
        'success': response.data['success'],
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to reject booking');
    }
  }
}

