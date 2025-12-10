import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project1/features/home/data/models/apartment_model.dart';

class ApartmentService {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApartmentService({required this.dio});

  Future<void> addApartment(ApartmentModel apartment) async {
    final token = await _storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized: token not found');
    }

    try {
      await dio.post(
        '/addApartment',
        data: apartment.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      final response = e.response;

      if (response == null) {
        throw Exception('Network error');
      }

      final data = response.data;

      // ✅ رسالة مباشرة
      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }

      // ✅ validation errors
      if (data is Map && data['errors'] != null) {
        final errors = data['errors'] as Map;
        final messages = <String>[];

        for (final value in errors.values) {
          if (value is List) {
            messages.addAll(value.map((e) => e.toString()));
          }
        }

        if (messages.isNotEmpty) {
          throw Exception(messages.join('\n'));
        }
      }

      throw Exception('Request failed (${response.statusCode})');
    }
  }

Future<List<ApartmentModel>> getApartments() async {
  try {
    final token = await _storage.read(key: 'token');
    dio.options.headers['Authorization'] = 'Bearer $token';  // قبل الطلب

    final response = await dio.get('/indexApartment');

    print(response.data);

    final list = response.data['apartments'] as List;
    return list.map((e) => ApartmentModel.fromJson(e)).toList();
  } on DioException catch (e) {
    throw Exception(e.message ?? 'Failed to load apartments');
  }
}




}
