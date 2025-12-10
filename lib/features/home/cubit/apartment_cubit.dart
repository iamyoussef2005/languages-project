import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/repositories/apartment_repository.dart';
import 'package:project1/features/home/data/models/apartment_model.dart';
import 'apartment_state.dart';

class ApartmentCubit extends Cubit<ApartmentState> {
  final ApartmentRepository repository;
  List<ApartmentModel> _originalList = [];

  ApartmentCubit(this.repository) : super(ApartmentInitial());

  Future<void> addApartment(ApartmentModel apartment) async {
    emit(ApartmentLoading());
    try {
      await repository.addApartment(apartment);
      emit(ApartmentBooked('Apartment added successfully'));
      await loadApartments();
    } catch (e) {
      emit(
        ApartmentFailure(e.toString().replaceFirst('Exception: ', '').trim()),
      );
    }
  }

Future<void> loadApartments() async {
  emit(ApartmentLoading());  // تأكد من أن الحالة هي تحميل
  try {
    final apartments = await repository.fetchApartments();  // استدعاء الخدمة
    _originalList = apartments;  // تخزين الشقق في _originalList

    if (apartments.isEmpty) {
      emit(ApartmentEmpty());  // إذا كانت الشقق فارغة
    } else {
      emit(ApartmentLoaded(apartments));  // إرسال الشقق التي تم تحميلها
    }
  } catch (e) {
    emit(
      ApartmentFailure(
        e.toString().replaceFirst('Exception: ', '').trim(),
      ),
    );
  }
}


  void search(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      emit(ApartmentLoaded(_originalList));
      return;
    }

    final filtered = _originalList.where((apt) {
      return apt.city.toLowerCase().contains(q) ||
          apt.province.toLowerCase().contains(q) ||
          apt.address.toLowerCase().contains(q);
    }).toList();

    filtered.isEmpty ? emit(ApartmentEmpty()) : emit(ApartmentLoaded(filtered));
  }
}
