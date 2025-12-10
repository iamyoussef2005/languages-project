class ApartmentModel {
  final String province;
  final String city;
  final String address;
  final double pricePerNight;
  final int bedrooms;
  final int bathroom;
  final int maxperson;
  final bool hasWifi;
  final bool hasParking;

  ApartmentModel({
    required this.province,
    required this.city,
    required this.address,
    required this.pricePerNight,
    required this.bedrooms,
    required this.bathroom,
    required this.maxperson,
    required this.hasWifi,
    required this.hasParking,
  });

  Map<String, dynamic> toJson() {
    return {
      'province': province,
      'city': city,
      'address': address,
      'price_per_night': pricePerNight,
      'bedrooms': bedrooms,
      'bathroom': bathroom,
      'maxperson': maxperson,
      'has_wifi': hasWifi,
      'has_parking': hasParking,
    };
  }

  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    return ApartmentModel(
      province: json['province'],
      city: json['city'],
      address: json['address'],
      pricePerNight:
          double.tryParse(json['price_per_night'].toString()) ?? 0.0,
      bedrooms: json['bedrooms'],
      bathroom: json['bathroom'],
      maxperson: json['maxperson'],
      hasWifi: json['has_wifi'] ?? false,
      hasParking: json['has_parking'] ?? false,
    );
  }
}

