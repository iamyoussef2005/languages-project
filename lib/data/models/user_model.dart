class UserModel {
  final String firstName;
  final String lastName;
  final String phone;
  final DateTime birthDate;
  final String profileImageUrl;
  final String idImageUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final String role; // 'tenant' or 'owner'

  bool get isCancelled =>
      status.toLowerCase() == 'rejected' || status.toLowerCase() == 'cancelled';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';

  bool get isTenant => role.toLowerCase() == 'tenant';

  // Helper method to get full image URL from storage path
  // Backend stores images in public storage, accessible at /storage/{path}
  static String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    // If already a full URL, return as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Construct full URL from storage path
    // Backend base URL is http://localhost:8000/api, so storage is at http://localhost:8000/storage
    const serverRoot = "http://localhost:8000";
    // Return full URL
    return "$serverRoot/storage/$path";
  }

  // Get full profile image URL
  String get fullProfileImageUrl => _getImageUrl(profileImageUrl);

  // Get full ID image URL
  String get fullIdImageUrl => _getImageUrl(idImageUrl);

  // Parse date from backend (handles Y-m-d format from Laravel date cast)
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    final dateStr = dateValue.toString();
    try {
      // Backend returns dates in Y-m-d format (e.g., "2024-01-15")
      // DateTime.parse can handle this format
      return DateTime.parse(dateStr);
    } catch (e) {
      // Fallback to current date if parsing fails
      return DateTime.now();
    }
  }

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.birthDate,
    required this.profileImageUrl,
    required this.idImageUrl,
    required this.status,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      phone: json["phone"] ?? "",
      birthDate: json["birth_date"] != null
          ? _parseDate(json["birth_date"])
          : DateTime.now(),
      // Backend uses personal_photo/id_photo; fall back to profile_image/id_image for mock compatibility
      profileImageUrl: json["personal_photo"] ?? json["profile_image"] ?? "",
      idImageUrl: json["id_photo"] ?? json["id_image"] ?? "",
      status: json["status"] ?? "",
      role: json["role"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "phone": phone,
      "birth_date": birthDate.toIso8601String(),
      "personal_photo": profileImageUrl,
      "id_photo": idImageUrl,
      "status": status,
      "role": role,
    };
  }
}
