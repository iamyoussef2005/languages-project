import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:project1/features/auth/cubit/auth_cubit.dart';
import 'package:project1/features/auth/cubit/auth_state.dart';
import 'package:project1/features/home/data/models/apartment_model.dart';
import 'package:project1/features/reservations/cubit/booking_cubit.dart';
import 'package:project1/features/reservations/cubit/booking_state.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  final ApartmentModel apartment;

  const ApartmentDetailsScreen({super.key, required this.apartment});

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _personsController = TextEditingController();

  static const String baseImageUrl = "http://127.0.0.1:8000/storage/";

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _bookApartment() {
    final authState = context.read<AuthCubit>().state;
    final apartment = widget.apartment;

    if (_startDateController.text.isEmpty ||
        _endDateController.text.isEmpty) {
      _showSnackbar("Error", "Please select start and end dates");
      return;
    }

    if (_personsController.text.isEmpty) {
      _showSnackbar("Error", "Please enter the number of persons");
      return;
    }

    final persons = int.tryParse(_personsController.text);
    if (persons == null || persons <= 0) {
      _showSnackbar("Error", "Invalid number of persons");
      return;
    }

    if (persons > apartment.maxperson) {
      _showSnackbar(
        "Limit Exceeded",
        "The maximum allowed persons for this apartment is ${apartment.maxperson}.",
      );
      return;
    }

    context.read<BookingCubit>().createBooking(
          apartmentId: apartment.id,
          checkIn: _startDateController.text,
          checkOut: _endDateController.text,
          personNumber: persons,
        );
  }

  void _showSnackbar(String title, String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: theme.colorScheme.primary,
        content: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final text = theme.textTheme;

    final authState = context.watch<AuthCubit>().state;
    final bool isOwner =
        authState is AuthLoggedIn && authState.user.role == "owner";

    final apartment = widget.apartment;
    final List<String> images = [
      if (apartment.firstPhotoUrl != null)
        baseImageUrl + apartment.firstPhotoUrl!,
      if (apartment.secondPhotoUrl != null)
        baseImageUrl + apartment.secondPhotoUrl!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Apartment Details",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: color.onPrimary,
          ),
        ),
        backgroundColor: color.primary,
        iconTheme: IconThemeData(color: color.onPrimary),
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            _showSnackbar("Error", state.message);
          } else if (state is BookingSuccess) {
            _showSnackbar("Success", state.message);
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CarouselSlider(
                  items: images.isNotEmpty
                      ? images
                          .map(
                            (img) => Image.network(
                              img,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                          .toList()
                      : [
                          Container(
                            height: 200,
                            color: color.surfaceVariant,
                            child: Center(
                              child: Icon(Icons.image_not_supported,
                                  size: 60, color: color.onSurfaceVariant),
                            ),
                          ),
                        ],
                  options: CarouselOptions(
                    height: 230,
                    autoPlay: true,
                    viewportFraction: 1,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(apartment.address,
                  style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700)),

              const SizedBox(height: 6),

              Text(
                "${apartment.city}, ${apartment.province}",
                style: text.bodyMedium?.copyWith(
                  color: color.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              _infoRow("Price per night",
                  "${apartment.pricePerNight.toStringAsFixed(0)} USD"),
              _infoRow("Bedrooms", "${apartment.bedrooms}"),
              _infoRow("Bathrooms", "${apartment.bathroom}"),
              _infoRow("Max Persons", "${apartment.maxperson}"),
              _infoRow("Wi-Fi", apartment.hasWifi ? "Available" : "Not Available"),
              _infoRow("Parking", apartment.hasParking ? "Available" : "Not Available"),

              if (!isOwner) ...[
                const SizedBox(height: 30),

                _dateInput("Select Start Date", _startDateController),
                const SizedBox(height: 16),
                _dateInput("Select End Date", _endDateController),

                const SizedBox(height: 20),

                _numberInput("Number of Persons", _personsController),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _bookApartment,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Book Apartment",
                      style: text.titleMedium?.copyWith(
                        color: color.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500, color: color.onSurfaceVariant)),
          Text(value,
              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _dateInput(String label, TextEditingController controller) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: label,
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today, color: color.primary),
              onPressed: () => _selectDate(controller),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        )
      ],
    );
  }

  Widget _numberInput(String label, TextEditingController controller) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter number of persons",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
