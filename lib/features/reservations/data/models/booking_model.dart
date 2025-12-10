import 'package:project1/features/home/data/models/apartment_model.dart';

class BookingModel {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // current | past | cancelled | active etc.
  final ApartmentModel apartment;

  BookingModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.apartment,
  });

  bool get isCancelled => status.toLowerCase() == "cancelled";

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? "",
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: (json['status'] ?? "").toString(),
      apartment: ApartmentModel.fromJson(
        json['apartment'] as Map<String, dynamic>,
      ),
    );
  }
}

