import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

// Services
import 'package:project1/data/services/auth_service.dart';
import 'package:project1/data/services/apartment_service.dart';
import 'package:project1/data/services/booking_service.dart';
// Repositories
import 'package:project1/data/repositories/auth_repository.dart';
import 'package:project1/data/repositories/apartment_repository.dart';
import 'package:project1/data/repositories/booking_repository.dart';

// Cubits
import 'package:project1/features/auth/cubit/auth_cubit.dart';
import 'package:project1/features/auth/cubit/profile_cubit.dart';
import 'package:project1/features/auth/presentation/pages/login_page.dart';
import 'package:project1/features/auth/presentation/pages/pending_aproval.dart';

import 'package:project1/features/home/cubit/apartment_cubit.dart';
import 'package:project1/features/home/presentation/pages/add_apartment_screen.dart';
import 'package:project1/features/home/presentation/pages/filter_page.dart';

import 'package:project1/features/reservations/cubit/booking_cubit.dart'; // إضافة BookingCubit
import 'package:project1/features/reservations/presentation/pages/bookings_page.dart'; // إضافة BookingsPage

// Pages
import 'package:project1/features/home/presentation/pages/home_page.dart';
import 'package:project1/features/auth/presentation/pages/signup_page.dart';
import 'package:project1/features/home/presentation/pages/landlord_home_screen.dart';

final GetIt getIt = GetIt.instance;

// Toggle this flag to switch between mock and real data
const bool USE_MOCK_DATA = false;

void setup() {
  // Register Dio (only used for real services)
  getIt.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
      ),
    ),
  );

  // Register Services (mock or real based on flag)
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<ApartmentService>(
    () => ApartmentService(dio: getIt()),
  );
  getIt.registerLazySingleton<BookingService>(
    () => BookingService(dio: getIt()),
  );

  // Register Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthService>()),
  );
  getIt.registerLazySingleton<ApartmentRepository>(
    () => ApartmentRepository(apartmentService: getIt()),
  );
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepository(getIt<BookingService>()),
  );

  // Register Cubits
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ApartmentCubit>(
    () => ApartmentCubit(getIt<ApartmentRepository>())..loadApartments(),
  );
  getIt.registerFactory<BookingCubit>(
    () => BookingCubit(getIt<BookingRepository>()), // إضافة BookingCubit
  );
}

void main() {
  setup();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => getIt<ProfileCubit>()),
        BlocProvider<ApartmentCubit>(
          create: (_) => getIt<ApartmentCubit>()..loadApartments(),
        ),
        BlocProvider<BookingCubit>(
          create: (_) => getIt<BookingCubit>(), // إضافة BookingCubit هنا
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(), // Start with login page
        routes: {
          "/login": (_) => LoginPage(),
          "/register": (_) => SignUpPage(),
          "/pendingApproval": (_) => PendingApprovalPage(),
          "/home": (_) => HomePage(),
          "/landlord_home": (_) => LandlordHomeScreen(),
          "/filtered_apartments": (_) => FilterPage(),
          "/bookings": (_) => BookingsPage(),
          '/add_apartment': (_) => const AddApartmentScreen(),
        },
      ),
    ),
  );
}
