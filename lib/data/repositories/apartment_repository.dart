import 'package:project1/data/services/apartment_service.dart';
import 'package:project1/features/home/data/models/apartment_model.dart';

class ApartmentRepository {
  final ApartmentService apartmentService;

  ApartmentRepository({required this.apartmentService});

  Future<void> addApartment(ApartmentModel apartment) async {
    await apartmentService.addApartment(apartment);
  }

  Future<List<ApartmentModel>> fetchApartments() async {
    return await apartmentService.getApartments();
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
    return await apartmentService.filterApartments(
      province: province,
      city: city,
      minPrice: minPrice,
      maxPrice: maxPrice,
      bedrooms: bedrooms,
      hasWifi: hasWifi,
      hasParking: hasParking,
    );
  }
}
