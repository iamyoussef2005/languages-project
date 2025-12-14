import 'package:project1/features/home/data/models/apartment_model.dart';

class BookingModel {
  final int id;
  final DateTime checkIn;
  final DateTime checkOut;
  final String status; // pending | approved | rejected | cancelled | completed
  final int guestsCount;
  final double totalPrice;
  final ApartmentModel apartment;

  BookingModel({
    required this.id,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.guestsCount,
    required this.totalPrice,
    required this.apartment,
  });

  bool get isCancelled => status.toLowerCase() == "cancelled";
  bool get isRejected => status.toLowerCase() == "rejected";
  bool get isPending => status.toLowerCase() == "pending";
  bool get isApproved => status.toLowerCase() == "approved";
  bool get isCompleted => status.toLowerCase() == "completed";

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: int.parse(json['id'].toString()),

      checkIn: DateTime.parse(json['check_in'].toString()),
      checkOut: DateTime.parse(json['check_out'].toString()),

      status: json['status']?.toString() ?? "",

      guestsCount: int.parse(json['person_number'].toString()),

      totalPrice: double.parse(json['total_price'].toString()),

      apartment: ApartmentModel.fromJson(json['apartment']),
    );
  }
}
