import 'package:project1/features/reservations/data/models/booking_model.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}

class BookingSuccess extends BookingState {
  final String message;
  BookingSuccess(this.message);
}

class BookingLoaded extends BookingState {
  final List<BookingModel> pending;
  final List<BookingModel> current;
  final List<BookingModel> past;
  final List<BookingModel> cancelled;
  final List<BookingModel> rejected;
  final List<BookingModel> completed;

  BookingLoaded({
    required this.pending,
    required this.current,
    required this.past,
    required this.cancelled,
    required this.rejected,
    required this.completed,
  });
}
