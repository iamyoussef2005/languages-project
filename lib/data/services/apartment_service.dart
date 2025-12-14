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
    final formData = FormData.fromMap({
      'province': apartment.province,
      'city': apartment.city,
      'address': apartment.address,
      'price_per_night': apartment.pricePerNight,
      'bedrooms': apartment.bedrooms,
      'bathroom': apartment.bathroom,
      'maxperson': apartment.maxperson,
      'has_wifi': apartment.hasWifi? 1 : 0,
      'has_parking': apartment.hasParking? 1 : 0,

   // First (required) photo
'first_photo': await MultipartFile.fromFile(
  apartment.firstPhotoFile!.path,
  filename: apartment.firstPhotoFile!.path.split('/').last,
),

// Second (optional) photo
if (apartment.secondPhotoFile != null)
  'second_photo': await MultipartFile.fromFile(
    apartment.secondPhotoFile!.path,
    filename: apartment.secondPhotoFile!.path.split('/').last,
  ),

    });

    await dio.post(
      '/addApartment',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  } on DioException catch (e) {
    final response = e.response;

    if (response == null) {
      throw Exception('Network error');
    }

    final data = response.data;

    if (data is Map && data['message'] != null) {
      throw Exception(data['message'].toString());
    }

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
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get('/indexApartment');

      print(response.data);

      final list = response.data['apartments'] as List;
      return list.map((e) => ApartmentModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load apartments');
    }
  }

  Future<List<ApartmentModel>> filterApartments({
  String? province,
  String? city,
  double? minPrice,
  double? maxPrice,
  int? bedrooms,
  bool? hasWifi,
  bool? hasParking,
}) async {
  try {
    final token = await _storage.read(key: 'token');
    dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await dio.get(
      '/ApartmentsFilter',
      queryParameters: {
        if (province != null) 'province': province,
        if (city != null) 'city': city,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (bedrooms != null) 'bedrooms': bedrooms,
        if (hasWifi != null) 'has_wifi': hasWifi ? 1 : 0,
        if (hasParking != null) 'has_parking': hasParking ? 1 : 0,
      },
    );

    final data = response.data['apartments']['data'] as List;

    return data.map((json) => ApartmentModel.fromJson(json)).toList();
  } on DioException catch (e) {
    throw Exception(e.message ?? 'Failed to filter apartments');
  }
}

}
