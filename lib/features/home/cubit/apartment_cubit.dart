import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/repositories/apartment_repository.dart';
import 'package:project1/features/home/data/models/apartment_model.dart';
import 'apartment_state.dart';

class ApartmentCubit extends Cubit<ApartmentState> {
  final ApartmentRepository repository;

  // القائمة الأصلية لكل الشقق
  List<ApartmentModel> _allApartments = [];

  ApartmentCubit(this.repository) : super(ApartmentInitial());

  Future<void> addApartment(ApartmentModel apartment) async {
    emit(ApartmentLoading());
    try {
      await repository.addApartment(apartment);
      emit(ApartmentBooked('Apartment added successfully'));
      await loadApartments();
    } catch (e) {
      emit(ApartmentFailure(e.toString().replaceFirst('Exception: ', '').trim()));
    }
  }

  Future<void> loadApartments() async {
    emit(ApartmentLoading());
    try {
      final apartments = await repository.fetchApartments();

      // حفظ القائمة الأصلية
      _allApartments = apartments;

      if (apartments.isEmpty) {
        emit(ApartmentEmpty());
      } else {
        emit(ApartmentLoaded(apartments));
      }
    } catch (e) {
      emit(ApartmentFailure(e.toString().replaceFirst('Exception: ', '').trim()));
    }
  }

  // البحث في الشقق
void search(String query) {
  if (state is! ApartmentLoaded) return;

  if (query.isEmpty) {
    emit(ApartmentLoaded(_allApartments));
    return;
  }

  final filtered = _allApartments.where((apartment) {
    return apartment.address.toLowerCase().contains(query.toLowerCase());
  }).toList();

  emit(ApartmentLoaded(filtered));
}


  Future<void> filterApartments({
    String? province,
    String? city,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    bool? hasWifi,
    bool? hasParking,
  }) async {
    emit(ApartmentLoading());
    try {
      final results = await repository.filterApartments(
        province: province,
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: bedrooms,
        hasWifi: hasWifi,
        hasParking: hasParking,
      );

      if (results.isEmpty) {
        emit(ApartmentEmpty());
      } else {
        emit(ApartmentLoaded(results));
      }
    } catch (e) {
      emit(ApartmentFailure(e.toString().replaceFirst('Exception: ', '').trim()));
    }
  }
}
