import 'package:project1/features/home/data/models/apartment_model.dart';

class BookingModel {
  final int id;
  final DateTime checkIn;
  final DateTime checkOut;
  final String status;
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

  bool get isCancelled => status == "cancelled";
  bool get isRejected => status == "rejected";
  bool get isPending => status == "pending";
  bool get isApproved => status == "approved";
  bool get isCompleted => status == "completed";

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,

      checkIn: DateTime.parse(json['check_in'].toString()),
      checkOut: DateTime.parse(json['check_out'].toString()),

      status: (json['status'] ?? '').toString().toLowerCase(),

      guestsCount:
          int.tryParse(json['person_number']?.toString() ?? '') ?? 0,

      totalPrice:
          double.tryParse(json['total_price']?.toString() ?? '') ?? 0.0,

      apartment: json['apartment'] != null
          ? ApartmentModel.fromJson(json['apartment'])
          : ApartmentModel.empty(),
    );
  }
}
