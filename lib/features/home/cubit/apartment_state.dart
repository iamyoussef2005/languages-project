import 'package:project1/features/home/data/models/apartment_model.dart';

abstract class ApartmentState {}

class ApartmentInitial extends ApartmentState {}

class ApartmentLoading extends ApartmentState {}

class ApartmentLoaded extends ApartmentState {
  final List<ApartmentModel> apartments;
  ApartmentLoaded(this.apartments);
}

class ApartmentEmpty extends ApartmentState {}

class ApartmentFailure extends ApartmentState {
  final String message;
  ApartmentFailure(this.message);
}

class ApartmentBooked extends ApartmentState {
  final String message;
  ApartmentBooked(this.message);
}
