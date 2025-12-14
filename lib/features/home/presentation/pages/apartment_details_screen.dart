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
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _bookApartment() async {
    final authState = context.read<AuthCubit>().state;
    final apartment = widget.apartment;

 

    // التحقق من التواريخ
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      _showSnackbar("Error", "Please select start and end dates");
      return;
    }

    // التحقق من عدد الأشخاص
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

    // إرسال بيانات الحجز إلى الـ API عبر BookingCubit
    final bookingCubit = context.read<BookingCubit>();
    bookingCubit.createBooking(
      apartmentId: apartment.id,
      checkIn: _startDateController.text,
      checkOut: _endDateController.text,
      personNumber: persons,
    );
  }

  // دالة لعرض الرسائل في Snackbar
  void _showSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            _showSnackbar("Error", state.message);
          }
          if (state is BookingSuccess) {
            _showSnackbar("Success", state.message);
            Navigator.pop(context); // العودة بعد الحجز الناجح
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صور الشقة في سلايدر
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
                            Image.network(
                              "https://via.placeholder.com/600x300",
                              width: double.infinity,
                              fit: BoxFit.cover,
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

                // العنوان
                Text(
                  apartment.address,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${apartment.city}, ${apartment.province}",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 20),

                // معلومات أساسية
                _infoRow(
                  "Price per night",
                  "${apartment.pricePerNight.toStringAsFixed(0)} USD",
                ),
                _infoRow("Bedrooms", "${apartment.bedrooms}"),
                _infoRow("Bathrooms", "${apartment.bathroom}"),
                _infoRow("Max Persons", "${apartment.maxperson}"),
                _infoRow(
                  "Wi-Fi",
                  apartment.hasWifi ? "Available" : "Not Available",
                ),
                _infoRow(
                  "Parking",
                  apartment.hasParking ? "Available" : "Not Available",
                ),
                if (!isOwner) ...[
                  const SizedBox(height: 30),

                  // التواريخ
                  Text(
                    "Select Start Date",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _startDateController,
                    readOnly: true,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: "Start date",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(_startDateController),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Select End Date",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _endDateController,
                    readOnly: true,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: "End date",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(_endDateController),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Number of Persons",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _personsController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: "Enter number of persons",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _bookApartment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Book Apartment",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
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
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
