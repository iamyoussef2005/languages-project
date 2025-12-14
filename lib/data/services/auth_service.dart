import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project1/data/models/user_model.dart';

class AuthService {
  // Backend URL configuration
  // For Android Emulator: use http://10.0.2.2:8000/api
  // For iOS Simulator: use http://localhost:8000/api or http://127.0.0.1:8000/api
  // For Physical Device: use http://YOUR_COMPUTER_IP:8000/api (e.g., http://192.168.1.100:8000/api)
  // To find your IP: Windows (ipconfig), Mac/Linux (ifconfig)
  static const String _baseUrl =
      "http://127.0.0.1:8000/api"; // Default for Android Emulator

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30), // Increased timeout
      receiveTimeout: const Duration(seconds: 30), // Increased timeout
      sendTimeout: const Duration(seconds: 30), // Added send timeout
      headers: {
        'Accept': 'application/json',
        // Don't set Content-Type here - Dio will set it automatically
        // For multipart/form-data (file uploads), Dio needs to set the boundary
      },
    ),
  );

  AuthService() {
    // Log base URL for debugging
    print("AuthService initialized with base URL: $_baseUrl");

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: "token");
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          // Log request for debugging
          print("Making request to: ${options.baseUrl}${options.path}");
          return handler.next(options);
        },
        onError: (error, handler) {
          // Log error details
          print(
            "Request error: ${error.requestOptions.baseUrl}${error.requestOptions.path}",
          );
          print("Error type: ${error.type}");
          print("Error message: ${error.message}");
          if (error.response != null) {
            print("Response status: ${error.response!.statusCode}");
            print("Response data: ${error.response!.data}");
          }
          return handler.next(error);
        },
      ),
    );
  }

  final _storage = const FlutterSecureStorage();

  // Test connection to backend
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get("/user");
      return response.statusCode == 200 || response.statusCode == 401;
    } catch (e) {
      print("Connection test failed: $e");
      return false;
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get("/user");
      return UserModel.fromJson(response.data["user"]);
    } catch (e) {
      final message = (e is DioException)
          ? (e.response?.data?["message"] ?? "Failed to load user")
          : "Failed to load user";
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _dio.post(
        "/login",
        data: {"phone": phone, "password": password},
      );

      final token = response.data["token"];

      if (token != null) {
        await _storage.write(key: "token", value: token);
        _dio.options.headers["Authorization"] = "Bearer $token";
      }

      return response.data;
    } catch (e) {
      String message = "Signing in failed";
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data["message"] != null) {
          message = data["message"];
        } else if (data["errors"] != null) {
          // Format validation errors
          final errors = data["errors"] as Map<String, dynamic>?;
          if (errors != null) {
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.map((e) => e.toString()));
              } else {
                errorMessages.add(value.toString());
              }
            });
            message = errorMessages.join(", ");
          }
        }
      }
      throw Exception(message);
    }
  }

  Future<UserModel> registerUser({
    required String firstName,
    required String lastName,
    required String phone,
    required DateTime birthDate,
    required String profileImagePath,
    required String idImagePath,
    required String password,
    required bool isTenant,
  }) async {
    try {
      // Format birth_date as Y-m-d (backend expects this format)
      final birthDateStr =
          "${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}";

      FormData formData = FormData.fromMap({
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
        "birth_date": birthDateStr,
        "password": password,
        "personal_photo": await MultipartFile.fromFile(
          profileImagePath,
          filename: profileImagePath.split('/').last,
        ),
        "id_photo": await MultipartFile.fromFile(
          idImagePath,
          filename: idImagePath.split('/').last,
        ),
        "role": isTenant ? "tenant" : "owner",
      });

      // Debug: Print request details
      print("Registering user with:");
      print("  first_name: $firstName");
      print("  last_name: $lastName");
      print("  phone: $phone");
      print("  birth_date: $birthDateStr");
      print("  role: ${isTenant ? "tenant" : "owner"}");
      print("  profileImagePath: $profileImagePath");
      print("  idImagePath: $idImagePath");

      final response = await _dio.post("/register", data: formData);

      return UserModel.fromJson(response.data["user"]);
    } catch (e) {
      String message = "Creating account failed";

      if (e is DioException) {
        // Handle different types of DioException
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          message =
              "Connection timeout while trying to reach $_baseUrl.\n\n"
              "Possible issues:\n"
              "• Laravel server is not running - Run: php artisan serve\n"
              "• Wrong base URL - Check if you're using the correct URL for your platform\n"
              "• Firewall blocking connection - Check Windows Firewall settings\n"
              "• Server not accessible - Verify server is running on port 8000\n\n"
              "Current URL: $_baseUrl";
        } else if (e.type == DioExceptionType.connectionError) {
          message =
              "Unable to connect to server at $_baseUrl.\n\n"
              "Troubleshooting:\n"
              "• Make sure the Laravel server is running (php artisan serve)\n"
              "• For Android Emulator: Use http://10.0.2.2:8000/api\n"
              "• For iOS Simulator: Use http://localhost:8000/api\n"
              "• For Physical Device: Use your computer's IP address (e.g., http://192.168.1.100:8000/api)\n"
              "• Check firewall settings";
        } else if (e.response != null) {
          // Server responded with error
          final statusCode = e.response!.statusCode;
          final data = e.response!.data;

          // Try to extract error message
          if (data != null) {
            if (data is Map<String, dynamic>) {
              if (data["message"] != null) {
                message = data["message"].toString();
              } else if (data["errors"] != null) {
                // Format validation errors
                final errors = data["errors"];
                if (errors is Map<String, dynamic>) {
                  final errorMessages = <String>[];
                  errors.forEach((key, value) {
                    if (value is List) {
                      errorMessages.addAll(value.map((e) => e.toString()));
                    } else {
                      errorMessages.add(value.toString());
                    }
                  });
                  message = errorMessages.join(", ");
                } else {
                  message = errors.toString();
                }
              } else if (data["error"] != null) {
                message = data["error"].toString();
              }
            } else if (data is String) {
              message = data;
            }
          }

          // Add status code info if no specific message found
          if (message == "Creating account failed" && statusCode != null) {
            message = "Server error (Status: $statusCode)";
          }
        } else {
          // Other DioException types
          message = e.message ?? "Network error occurred";
        }
      } else {
        // Non-DioException errors
        message = e.toString();
      }

      // Print error for debugging
      print("Registration error: $message");
      if (e is DioException && e.response != null) {
        print("Response status: ${e.response!.statusCode}");
        print("Response data: ${e.response!.data}");
      }

      throw Exception(message);
    }
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    File? personalPhoto,
    File? idPhoto,
  }) async {
    try {
      final birthDateStr =
          "${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}";

      FormData formData = FormData.fromMap({
        "first_name": firstName,
        "last_name": lastName,
        "birth_date": birthDateStr,
        if (personalPhoto != null)
          "personal_photo": await MultipartFile.fromFile(personalPhoto.path),
        if (idPhoto != null)
          "id_photo": await MultipartFile.fromFile(idPhoto.path),
      });

      final response = await _dio.post(
        "/profile",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return UserModel.fromJson(response.data["user"]);
    } catch (e) {
      String message = "Updating profile failed";
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data["message"] != null) {
          message = data["message"];
        } else if (data["errors"] != null) {
          // Format validation errors
          final errors = data["errors"] as Map<String, dynamic>?;
          if (errors != null) {
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.map((e) => e.toString()));
              } else {
                errorMessages.add(value.toString());
              }
            });
            message = errorMessages.join(", ");
          }
        }
      }
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post("/logout");
      await _storage.delete(key: "token");
      _dio.options.headers.remove("Authorization");
    } catch (e) {
      // Even if logout fails on backend, clear local token
      await _storage.delete(key: "token");
      _dio.options.headers.remove("Authorization");
      final message = (e is DioException)
          ? (e.response?.data?["message"] ?? "Signing out failed")
          : "Signing out failed";
      throw Exception(message);
    }
  }
}
