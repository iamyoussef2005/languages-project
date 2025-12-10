import 'package:project1/data/services/apartment_service.dart';
import 'package:project1/features/home/data/models/apartment_model.dart';

class ApartmentRepository {
  final ApartmentService apartmentService;

  ApartmentRepository({required this.apartmentService});

  Future<void> addApartment(ApartmentModel apartment) async {
    await apartmentService.addApartment(apartment);
  }

Future<List<ApartmentModel>> fetchApartments() async {
  return await apartmentService.getApartments();  // استدعاء الدالة من الخدمة
}

}
