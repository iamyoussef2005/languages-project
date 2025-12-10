import 'package:equatable/equatable.dart';
import 'package:project1/features/reservations/data/models/booking_model.dart';

abstract class BookingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingModel> current;
  final List<BookingModel> past;
  final List<BookingModel> cancelled;

  BookingLoaded({
    required this.current,
    required this.past,
    required this.cancelled,
  });

  @override
  List<Object?> get props => [current, past, cancelled];
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingUpdating extends BookingState {}

