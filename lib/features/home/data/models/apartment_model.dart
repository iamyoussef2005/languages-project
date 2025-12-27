import 'dart:io';

class ApartmentModel {
  final int id; // إضافة الخاصية id
  final String province;
  final String city;
  final String address;
  final double pricePerNight;
  final int bedrooms;
  final int bathroom;
  final int maxperson;
  final bool hasWifi;
  final bool hasParking;
  final String? firstPhotoUrl;
  final String? secondPhotoUrl;
  final File? firstPhotoFile;
  final File? secondPhotoFile;

  ApartmentModel({
    required this.id, // إضافة id في المنشئ
    required this.province,
    required this.city,
    required this.address,
    required this.pricePerNight,
    required this.bedrooms,
    required this.bathroom,
    required this.maxperson,
    required this.hasWifi,
    required this.hasParking,
    this.firstPhotoUrl,
    this.secondPhotoUrl,
    this.firstPhotoFile,
    this.secondPhotoFile,
  });
  factory ApartmentModel.empty() {
    return ApartmentModel(
      id: 0, province: '', city: '', address: '', pricePerNight: 0, bedrooms: 0, bathroom: 0, maxperson: 0, hasWifi: false, hasParking: false,
      
    );
  }
  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    return ApartmentModel(
      id: json['id'], // التأكد من استخراج id من الـ JSON
      province: json['province'],
      city: json['city'],
      address: json['address'],
      pricePerNight: double.tryParse(json['price_per_night'].toString()) ?? 0,
      bedrooms: json['bedrooms'],
      bathroom: json['bathroom'],
      maxperson: json['maxperson'],
      hasWifi: json['has_wifi'] ?? false,
      hasParking: json['has_parking'] ?? false,
      firstPhotoUrl: json['first_photo'],
      secondPhotoUrl: json['second_photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // تضمين id في التصدير إلى JSON
      'province': province,
      'city': city,
      'address': address,
      'price_per_night': pricePerNight,
      'bedrooms': bedrooms,
      'bathroom': bathroom,
      'maxperson': maxperson,
      'has_wifi': hasWifi ? "1" : "0",
      'has_parking': hasParking ? "1" : "0",
      'first_photo': firstPhotoUrl,
      'second_photo': secondPhotoUrl,
    };
  }
}
